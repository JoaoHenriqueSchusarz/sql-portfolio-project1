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