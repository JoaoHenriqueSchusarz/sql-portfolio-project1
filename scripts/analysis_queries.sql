/* ============================================================
   OLIST – QUERIES DE ANÁLISE
   Requisitos: MySQL 8.0+ (para CTE e funções janela)
   Autor: João Henrique Schusarz Salvador
  ============================================================ */

CREATE DATABASE IF NOT EXISTS olist_data
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE olist_data;

/* ============================================================
   1. Confirmação dos dados e qualidade
  ============================================================ */

SELECT 'orders'  AS tabela, COUNT(*) AS linhas FROM olist_orders
UNION ALL
SELECT 'items'   AS tabela, COUNT(*) FROM olist_order_items
UNION ALL
SELECT 'products', COUNT(*) FROM olist_products
UNION ALL
SELECT 'customers', COUNT(*) FROM olist_customers
UNION ALL
SELECT 'payments', COUNT(*) FROM olist_order_payments
UNION ALL
SELECT 'reviews',  COUNT(*) FROM olist_order_reviews
UNION ALL
SELECT 'sellers',  COUNT(*) FROM olist_sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM olist_geolocation;

-- Duplicidade de chaves usuais (espera-se 0)
SELECT order_id, COUNT(*) c
FROM olist_orders
GROUP BY order_id
HAVING c > 1;

SELECT order_id, order_item_id, COUNT(*) c
FROM olist_order_items
GROUP BY order_id, order_item_id
HAVING c > 1;

-- Nulos críticos
SELECT
  SUM(order_id IS NULL) AS nulos_order_id,
  SUM(customer_id IS NULL) AS nulos_customer_id
FROM olist_orders;

SELECT
  SUM(order_id IS NULL) AS nulos_order_id,
  SUM(order_item_id IS NULL) AS nulos_order_item_id,
  SUM(product_id IS NULL) AS nulos_product_id,
  SUM(seller_id IS NULL) AS nulos_seller_id
FROM olist_order_items;

-- etc. para as outras tabelas

-- Discrepância de categorias (produtos vs tradução)
SELECT 'products_distinct_cats' AS fonte, COUNT(DISTINCT product_category_name) AS q
FROM olist_products
UNION ALL
SELECT 'translation_distinct_cats', COUNT(DISTINCT product_category_name) AS q
FROM product_category;
-- Espera-se que o número de categorias na tradução seja maior ou igual ao número de categorias nos produtos
-- (pois pode haver categorias sem produtos, mas não o contrário)

-- Quais categorias de produtos não estão na tabela de tradução?
SELECT DISTINCT p.product_category_name
FROM olist_products p
LEFT JOIN product_category t
  ON t.product_category_name = p.product_category_name
WHERE t.product_category_name IS NULL
ORDER BY 1;

/* ============================================================
   2. Análises exploratórias
  ============================================================ */

-- Quantidade de pedidos por mês

SELECT monthname(order_approved_at) AS month_approved, 
       MONTH(order_approved_at) AS num_month,
	   COUNT(DISTINCT order_id) AS count_orders
FROM olist_orders
WHERE order_approved_at IS NOT NULL
GROUP BY month_approved,MONTH(order_approved_at)
ORDER BY MONTH(order_approved_at);
-- Obs: a função MONTH() é usada para ordenar corretamente os meses do ano na visualização

-- Quantidade de produtos por categoria (maior e menor)
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria,
       COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
GROUP BY op.product_category_name
)
SELECT categoria,
       contagem
FROM contagem_categoria
WHERE contagem = (SELECT MAX(contagem) FROM contagem_categoria))
UNION
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria,
       COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
GROUP BY op.product_category_name
)
SELECT categoria,
       contagem
FROM contagem_categoria
WHERE contagem = (SELECT MIN(contagem) FROM contagem_categoria));

-- Quantidade de pedidos por estado (maior e menor)

WITH contagem AS (
SELECT os.seller_state AS uf,
		COUNT(DISTINCT od.order_id) AS count_orders
FROM olist_orders od
INNER JOIN olist_order_items oi ON oi.order_id = od.order_id
INNER JOIN olist_sellers os ON os.seller_id = oi.seller_id
INNER JOIN olist_customers oc ON oc.customer_id = od.customer_id 
							AND oc.customer_state = os.seller_state
GROUP BY uf
), extremos AS (
SELECT MAX(c.count_orders) AS max_orders,
       MIN(c.count_orders) AS min_orders
FROM contagem c
)
SELECT c.uf, c.count_orders,
CASE 
    WHEN count_orders =  e.max_orders THEN 'max'
    WHEN count_orders =  e.min_orders THEN 'min'
END AS max_or_min
FROM contagem c
INNER JOIN extremos e
ON c.count_orders IN (e.max_orders, e.min_orders)
ORDER BY c.count_orders DESC, c.uf;

-- O ticket médio, máximo e mínimo dos pedidos

WITH valor AS (
  SELECT op.order_id, SUM(op.payment_value) AS valores
  FROM olist_order_payments op
  GROUP BY op.order_id
)
SELECT 
  ROUND(AVG(valores),2) AS avg_payments,
  MAX(valores) AS max_payments,
  MIN(valores) AS min_payments
FROM valor
WHERE valores != 0;
-- Obs: o filtro WHERE valores != 0 é usado para evitar que pedidos com valor zero (possivelmente cancelados) distorçam o ticket mínimo

-- Verificação do tempo entre realizar o pedido e aprovar o pagamento por meios de pagamento

WITH order_type 
AS(
SELECT     op.order_id, 
           op.payment_type AS p_type, 
	         od.order_purchase_timestamp AS purchase, 
		       od.order_approved_at        AS approved 
FROM       olist_data.olist_order_payments op
INNER JOIN olist_orders od
ON   	     od.order_id = op.order_id
WHERE 	   op.payment_type NOT IN ('not_defined','voucher')
AND        od.order_status NOT IN ('canceled','unavailable')
), diff 
AS(
SELECT     p_type, 
		       DATEDIFF(approved,purchase) AS diff_date
FROM       order_type
)
SELECT     d.p_type, 
	         ROUND(AVG(d.diff_date)) AS avg_dif,
           MAX(d.diff_date)        AS max_diff,
           MIN(d.diff_date)        AS min_diff
FROM       diff d
GROUP BY   d.p_type
ORDER BY   max_diff DESC;

-- Quanto tempo em média leva para um pedido ser entregue?

-- Verifica se há datas nulas ou inconsistentes combase em status e datas de entrega 

SELECT DISTINCT order_status
FROM olist_orders
WHERE order_delivered_carrier_date IS NOT NULL
  OR order_delivered_customer_date IS NOT NULL
  OR order_estimated_delivery_date IS NOT NULL;

SELECT COUNT(*) AS total, 
       SUM(order_delivered_carrier_date IS NULL) AS nulos_carrier,
       SUM(order_delivered_customer_date IS NULL) AS nulos_customer,
       SUM(order_estimated_delivery_date IS NULL) AS nulos_estimated,
       SUM(order_delivered_carrier_date < order_purchase_timestamp) AS inconsist_carrier,
       SUM(order_delivered_customer_date < order_purchase_timestamp) AS inconsist_customer,
       SUM(order_estimated_delivery_date < order_purchase_timestamp) AS inconsist_estimated
FROM olist_orders
WHERE order_status = 'delivered';

-- Cálculo do tempo médio de entrega (em dias)
WITH datas AS (
SELECT 
	   DATEDIFF(order_delivered_customer_date,order_purchase_timestamp) AS diff
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
AND   order_status NOT IN ('canceled','unavailable')
)
SELECT ROUND(AVG(diff)) AS avg_delivered_date
FROM datas;

-- Quanto tempo em média leva para um pedido ser entregue por categoria?
WITH datas AS (
SELECT     op.product_category_name AS category,
	       DATEDIFF(od.order_delivered_customer_date,od.order_purchase_timestamp) AS diff
FROM  	   olist_orders od
INNER JOIN olist_order_items oi
	    ON oi.order_id   = od.order_id
INNER JOIN olist_products op
		ON oi.product_id = op.product_id
WHERE      order_delivered_customer_date IS NOT NULL
  AND      order_purchase_timestamp      IS NOT NULL
  AND      order_status NOT IN ('canceled','unavailable')
  AND      op.product_category_name <> ""
)
SELECT category, ROUND(AVG(diff)) AS avg_delivered_date
FROM datas
GROUP BY   category
ORDER BY   avg_delivered_date DESC
LIMIT 10;
-- Obs: categorias com poucos pedidos podem distorcer a média. Uma solução seria filtrar por categorias com um número mínimo de pedidos

-- Quanto tempo em média leva para um pedido ser entregue por categorias com um número mínimo de pedidos
WITH datas AS (
SELECT     op.product_category_name AS category,
         DATEDIFF(od.order_delivered_customer_date,od.order_purchase_timestamp) AS diff 
FROM       olist_orders od
INNER JOIN olist_order_items oi
      ON oi.order_id   = od.order_id
INNER JOIN olist_products op
    ON oi.product_id = op.product_id
WHERE      order_delivered_customer_date IS NOT NULL
  AND      order_purchase_timestamp      IS NOT NULL
  AND      order_status NOT IN ('canceled','unavailable')
  AND      op.product_category_name <> ""
), filtro AS (
SELECT category
FROM   datas
GROUP BY category
HAVING COUNT(*) >= 50
)
SELECT d.category, ROUND(AVG(d.diff)) AS avg_delivered_date
FROM   datas d
INNER JOIN filtro f
ON d.category = f.category
GROUP BY d.category
ORDER BY avg_delivered_date DESC
LIMIT 10;
-- Obs: o número mínimo de pedidos (neste caso, 50) pode ser ajustado conforme necessário

-- Qual é a taxa de atraso na entrega?
WITH atraso AS (
SELECT 
       CASE 
           WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 1
           ELSE 0
       END AS is_late
FROM olist_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_status NOT IN ('canceled','unavailable')
) 
SELECT 
       ROUND(AVG(is_late) * 100, 2) AS pct_late 
FROM atraso;
-- Obs: o resultado é multiplicado por 100 para apresentar a porcentagem