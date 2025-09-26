# Projeto SQL - Análise do E-commerce Brasileiro (Olist)

## Conjunto de Dados Público - Kaggle

Este projeto utiliza o [Conjunto de dados públicos de comércio eletrônico brasileiro da Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), disponível no Kaggle.

O dataset reúne informações de pedidos realizados entre 2016 e 2018 em diversos marketplaces no Brasil, incluindo dados de:

* Pedidos (orders)
* Itens vendidos (order_items)
* Clientes (customers)
* Vendedores (sellers)
* Produtos (products)
* Avaliações de clientes (reviews)
* Pagamentos (payments)

No total, são 100 mil pedidos, com tabelas que permitem análises completas de comportamento de clientes, desempenho logístico e performance de vendas.

## Objetivo do Projeto

Construir e popular um banco de dados relacional no MySQL a partir dos arquivos CSV. Executar queries exploratórias para entender a estrutura dos dados.
Com a base estudada criar-se consultas analíticas para responder perguntas de negócio, como:
* Quais categorias tiveram a maior e menor quantidade vendida?
* Quais categorias tiveram a maior e menor quantidade vendida em Curitiba?
* Quais categorias tiveram o menor tempo de recompra?
* Qual o ticket médio, máximo e mínimo dos pedidos?
* Quanto tempo em média leva para um pedido ser entregue?
* Qual é a taxa de atraso na entrega?

## Tecnologias Utilizadas no Projeto

* MySQL 8.0 → criação do banco de dados, modelagem das tabelas e consultas SQL (exploratórias e analíticas).
* MySQL Workbench → interface gráfica para administração do banco, execução de queries e carga inicial dos dados.
* Kaggle → fonte do dataset público [Conjunto de dados públicos de comércio eletrônico brasileiro da Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
* Visual Studio Code → criação de documentos comprobatórios de criação, iportação e análise de dados.
* Git & GitHub → versionamento do projeto e publicação do portfólio.
* Power BI/Tableau → visualização de dashboards.

# Início no MySQL

Para conseguir fazer as análises e queries no MySQL, precisamos realizar o load do dataset da Olist. Porém, antes de iniciar o carregamento dos arquivos CSVs precisamos criar o local que iremos armazenar-los(Banco de Dados).

## 1 - Criação da Database 

Nesta etapa criei o banco de dados `olist_data`, que será usado para armazenar todas as tabelas importadas do dataset da Olist.
Usei o UTF-8, pois ele suporta uma grande quantidade de caracteres internacionais e emojis, ele nada mais é que uma codificação de caracteres Unicode que armazena a maioria dos caracteres de diversas línguas e símbolos, sendo a codificação recomendada para bancos de dados SQL.

O comando abaixo cria o banco de dados com suporte e caracteres UTF-8:
```sql
-- 1) Criação da data base
CREATE DATABASE IF NOT EXISTS olist_data
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE olist_data;
```
## 2 - Criação das Tabelas e Importaçãos dos CSVs

Precisamos criar as tabelas que iremos importar da nossa base de dados disponibilizada pelo Kaggle, no nosso MySQL Workbench. Vou descrever duas criações abaixo, as demais deixei como histórico de produção na pasta Script com o código completo de criação e importação das tabelas: [create_tables.sql](scripts/create_tables.sql)

### 2.1 - Tabelas Utilizadas no Projeto

Foram utilizados 9 arquivos CSVs do dataset da Olist, cada um representando uma entidade no banco de dados relacional:

| Arquivo CSV                           | Tabela no MySQL                     | Descrição                                                    |
|---------------------------------------|-------------------------------------|--------------------------------------------------------------|
| `olist_customers_dataset.csv`         | `olist_customers`                   | Dados dos clientes (ID, CEP, cidade, estado).                |
| `olist_geolocation_dataset.csv`       | `olist_geolocation`                 | Coordenadas geográficas associadas a CEPs.                   |
| `olist_order_items_dataset.csv`       | `olist_order_items`                 | Itens dos pedidos: produto, vendedor, preço, frete.          |
| `olist_order_payments_dataset.csv`    | `olist_order_payments`              | Pagamentos: método, número de parcelas, valor.               |
| `olist_order_reviews_dataset.csv`     | `olist_order_reviews`               | Avaliações dos pedidos: nota, comentário, datas.             |
| `olist_orders_dataset.csv`            | `olist_orders`                      | Pedidos: datas de compra, aprovação, envio, entrega, status. |
| `olist_products_dataset.csv`          | `olist_products`                    | Produtos: categoria, peso, dimensões.                        |
| `olist_sellers_dataset.csv`           | `olist_sellers`                     | Vendedores: ID, CEP, estado.                                 |
| `product_category_name_translation.csv` | `product_category_name_translation` | Tradução de categorias de produtos (pt → en).                |


### 2.2 Criação da Tabela e Importação do CSV - `olist_customers`
A tabela `olist_customers` contém os dados básicos dos clientes, como identificador único, CEP, cidade e estado.  
Ela é importante para análises de localização, distribuição de pedidos e perfil de clientes.

```sql
USE olist_data;

CREATE TABLE olist_customers (
   customer_id              CHAR(32) NOT NULL,
   customer_unique_id       CHAR(32) NOT NULL,
   customer_zip_code_prefix VARCHAR(10) NOT NULL,
   customer_city            VARCHAR(100) NOT NULL,
   customer_state           CHAR(2) NOT NULL,
   PRIMARY KEY (customer_id)
);

```
Agora que criamos a tabela `olist_customers`, precisamos realizar o `LOAD DATA INFILE` e carregar os dados no esqueleto da tabela criada. Para não haver erros ou até para revalidar que estamos inserindo na tabela apenas os dadoscarregados da base, utilizamos o `TRUNCATE TABLE`, que basicamente ele irá apagar todos os dados que podem estar já estar armazenados, deixando apenas o esqueleto da tabela.

```sql
USE olist_data;

TRUNCATE TABLE olist_customers;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_customers_dataset.csv'
INTO TABLE olist_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'     -- <- trocado para \n
IGNORE 1 LINES
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

```
Podemos realizar duas *queries* para confirmar; quantas linhas foram carregadas e outra, mostrando 10 linhas para visualizar se os dados foram inseridos corretamente em suas respectativas colunas, como a formatação.

Aqui solicitamos a contagem total de linhas inseridas na tabela.
```sql
SELECT COUNT(*) FROM olist_customers;
```

<p align="center">
  <img src="docs/olist_customers_count.png" alt="Contagem de clientes Olist" style="max-width:80%;">
</p>

Agora, solicitamos as 10 primeiras linhas de toda a tabela.
```sql
SELECT COUNT(*) FROM olist_customers;
```

<p align="center">
  <img src="docs/olist_customers_limit.png" alt="Query All clientes Olist" style="max-width:80%;">
</p>

### 2.3 - Criação da Tabela e Importação do CSV - `olist_orders`
Na tabela `olist_orders`, o processo fugiu do padrão:
- O `LOAD DATA INFILE` precisou tratar campos de data, utilizando `NULLIF` para evitar erros em valores vazios.

Essa adaptação foi importante para:
- Manter a consistência referencial entre as tabelas.
- Garantir que valores obrigatórios estivessem devidamente preenchidos.
- Tratar corretamente dados nulos durante a importação.

Esse tipo de ajuste reflete a realidade de muitos projetos de dados, em que os datasets não estão 100% prontos para uso e exigem correções pontuais durante a modelagem.

```sql
CREATE TABLE olist_orders (
			 order_id VARCHAR(50) NOT NULL,
             customer_id VARCHAR(50) NOT NULL,
             order_status VARCHAR(30) NOT NULL,
             order_purchase_timestamp DATETIME NOT NULL,
             order_approved_at DATETIME NOT NULL,
             order_delivered_carrier_date DATETIME NOT NULL,
             order_delivered_customer_date DATETIME NOT NULL,
             order_estimated_delivery_date DATETIME NOT NULL,
             PRIMARY KEY(order_id,customer_id)
);

TRUNCATE TABLE olist_orders;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_orders_dataset.csv' 
INTO TABLE olist_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id,customer_id,order_status,@order_purchase_timestamp,@order_approved_at,@order_delivered_carrier_date,@order_delivered_customer_date,@order_estimated_delivery_date)
SET 
 order_purchase_timestamp = NULLIF(@order_purchase_timestamp,''),
 order_approved_at = NULLIF(@order_approved_at,''),
 order_delivered_carrier_date = NULLIF(@order_delivered_carrier_date,''),
 order_delivered_customer_date = NULLIF(@order_delivered_customer_date,''),
 order_estimated_delivery_date = NULLIF(@order_estimated_delivery_date,'');
```
Realizando as *queries* para confirmar; quantas linhas foram carregadas e outra, mostrando 10 linhas para visualizar se os dados foram inseridos corretamente em suas respectativas colunas, como a formatação.

Aqui solicitamos a contagem total de linhas inseridas na tabela.
```sql
SELECT COUNT(*) FROM olist_orders;
```
<p align="center">
  <img src="docs/olist_orders_count.png" alt="Contagem de orders Olist" style="max-width:80%;">
</p>

Agora, solicitamos as 10 primeiras linhas de toda a tabela.
```sql
SELECT COUNT(*) FROM olist_orders;
```

<p align="center">
  <img src="docs/olist_orders_limit.png" alt="Query All orders Olist" style="max-width:80%;">
</p>

### Observações sobre Integridade Referencial

Durante a modelagem, tentei criar chaves estrangeiras (FKs) entre as tabelas para garantir integridade referencial.  
Porém, o dataset público da Olist possui linhas órfãs (ex.: `customer_id` presente em `olist_orders` mas ausente em `olist_customers`).  

Por esse motivo, não foi possível aplicar algumas FKs sem modificar os dados originais.  
Optei por não alterar os dados, para manter a fidelidade ao dataset original do Kaggle.  

No entanto, as relações lógicas entre as tabelas foram consideradas em todas as queries analíticas via `JOIN`.

# Queries Exploratórias 

## Quais categorias tiveram a maior e menor quantidade vendida?

### Análise Exploratória e Qualidade dos Dados

Ao realizar a query para responder "Quais categorias tiveram a maior e menor quantidade vendida?", identifiquei uma inconsistência entre as tabelas `olist_products` e `product_category_name_translation`.

- A tabela `olist_products` possui 74 categorias distintas.
- A tabela `product_category_name_translation` possui apenas 71 categorias distintas.

Isso significa que algumas categorias presentes em `olist_products` não têm correspondência na tabela de tradução.  
Esse tipo de discrepância é comum em datasets públicos e reforça a importância da etapa de análise exploratória antes da modelagem final.

Abaixo mostro como em uma `query` conseguimos validar os dados que existem na `olist_products`, e na `product_category_name_translation` esta como NULL.

```sql
SELECT DISTINCT op.product_category_name AS products,  odp.product_category_name AS category
FROM olist_products op
LEFT JOIN olist_data.product_category odp
ON odp.product_category_name = op.product_category_name
WHERE odp.product_category_name IS NULL;
```
Abaixo verificamos que apenas dois dados estão sem o real complemento, sendo a primeira linha apenas uma diferença de formatação de dados, onde na `olist_products` o dado foi inserido como campo vazio (" "), e na `product_category_name_translation` o dado foi colocado como NULL.

<p align="center">
  <img src="docs/olist_select_null_result.png" alt="Query DISTINCT category Olist" style="max-width:80%;">
</p>

Para não descartar dados relevantes, optei por utilizar um LEFT JOIN partindo da `olist_products`.  
Dessa forma, todas as categorias são mantidas, e aquelas sem tradução aparecem como `NULL` ou "não identificadas".  

Esse tratamento garante consistência na análise, preserva os dados originais e ao mesmo tempo evidencia lacunas existentes no dataset público.

### Análise e Criação da Query

Para conseguir realizar a query onde mostre o `MAX` e, o `MIN` acompanhado da categoria, utilizei o recurso `WITH` (CTE – Common Table Expression).  
O `WITH` permite criar uma tabela temporária dentro da consulta (no caso, chamada `contagem_categoria`).  
Isso deixa a query mais organizada, evita repetição de código (subquery) e facilita reuso — em vez de escrever o mesmo `SELECT ... GROUP BY` duas vezes, defini uma vez na CTE e depois referenciei.

A lógica foi:
1. Criar a CTE `contagem_categoria` com o total de itens vendidos por categoria, tabela temporária,
2. Consultar essa CTE duas vezes: uma filtrando o máximo (`MAX`) e outra filtrando o mínimo (`MIN`),
3. Juntar os dois resultados em uma única saída usando `UNION`.

```sql
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria, COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
GROUP BY op.product_category_name
)
SELECT categoria, contagem
FROM contagem_categoria
WHERE contagem = (SELECT MAX(contagem) FROM contagem_categoria))
UNION
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria, COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
GROUP BY op.product_category_name
)
SELECT categoria, contagem
```
Rodando a query temos como resultado que entre 2016 e 2018, a categoria que mais vendeu e menos vendeu respectativamente:

<p align="center">
  <img src="docs/olist_select_maxmin_result.png" alt="Query MAX AND MIN category Olist" style="max-width:80%;">
</p>

# Quais categorias tiveram a maior e menor quantidade vendida em Curitiba?

### Análise Exploratória e Qualidade dos Dados

Como quero apenas Curitiba, logo penso que tanto compradores (`CUSTOMERS`) e vendedore (`SELLERS`), precisam estar filtrados com a cidade de Curitiba. Para conseguir esses dados precisamos pensar em quais dados queremos filtrar nesta query. 

Assim, para obter um resultado condizente com o que estamos buscando analisar precisamos inserir nessa query os dados das tabelas: `olist_products`, `olist_order_items`, `olist_customers`, e `olist_sellers`. Usando as funções `INNER JOIN` e `WHERE` , conseguimos juntar os dados na tabela temporária filtrando pela cidade de Curitiba.

```sql
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria, COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
INNER JOIN olist_sellers os
ON os.seller_id = oi.seller_id
INNER JOIN olist_customers oc
ON oc.customer_city = os.seller_city
AND oc.customer_state = os.seller_state
AND oc.customer_zip_code_prefix = os.seller_zip_code_prefix
WHERE os.seller_city = 'curitiba'
GROUP BY op.product_category_name
)
SELECT categoria, contagem
FROM contagem_categoria
WHERE contagem = (SELECT MAX(contagem) FROM contagem_categoria))
UNION
(WITH contagem_categoria AS (
SELECT op.product_category_name AS categoria, COUNT(oi.seller_id) AS contagem
FROM olist_products op
LEFT JOIN olist_order_items oi
ON oi.product_id = op.product_id
INNER JOIN olist_sellers os
ON os.seller_id = oi.seller_id
INNER JOIN olist_customers oc
ON oc.customer_city = os.seller_city
AND oc.customer_state = os.seller_state
AND oc.customer_zip_code_prefix = os.seller_zip_code_prefix
WHERE os.seller_city = 'curitiba'
GROUP BY op.product_category_name
)
SELECT categoria, contagem
FROM contagem_categoria
WHERE contagem = (SELECT MIN(contagem) FROM contagem_categoria));
```
Com isso verificamos que o resultado difere comparado ao geral das cidades do Brasil.

<p align="center">
  <img src="docs/olist_select_maxmincuritiba_result.png" alt="Query category MAX AND MIN CURITIBA Olist" style="max-width:80%;">
</p>


