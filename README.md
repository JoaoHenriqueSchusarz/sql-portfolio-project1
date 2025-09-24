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
* Quais categorias tiveram o menor tempo de recompra?
* Qual o ticket médio, máximo e mínimo dos pedidos?
* Quanto tempo em média leva para um pedido ser entregue?
* Qual é a taxa de atraso na entrega?
* Previsão de vendas para os próximo meses

## Previsão de Vendas Futuras - Olist

Após a consolidação das vendas mensais no MySQL, exportei os dados para Python e utilizei o modelo Prophet (Meta) para prever as vendas futuras. 
Abaixo um exemplo de gráfico gerado:


## Tecnologias Utilizadas no Projeto

* MySQL 8.0 → criação do banco de dados, modelagem das tabelas e consultas SQL (exploratórias e analíticas).
* MySQL Workbench → interface gráfica para administração do banco, execução de queries e carga inicial dos dados.
* Kaggle → fonte do dataset público [Conjunto de dados públicos de comércio eletrônico brasileiro da Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
* Python 3.x → análise de dados e previsão de vendas futuras.
    * Pandas → manipulação de dados.
    * Matplotlib/Seaborn → visualizações exploratórias.
    * Prophet (Meta/Facebook) → modelo de previsão de vendas.
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
