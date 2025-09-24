-- Neste documento deixei todos os passos para a criação das tabelas do banco de dados e importação dos dados.

-- Criação do banco de dados e importação dos dados: olist_customers
CREATE DATABASE IF NOT EXISTS olist_data
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE olist_data;

CREATE TABLE olist_customers (
            customer_id CHAR(32) NOT NULL,
            customer_unique_id CHAR(32) NOT NULL,
            customer_zip_code_prefix VARCHAR(10) NOT NULL,
            customer_city VARCHAR(100) NOT NULL,
            customer_state CHAR(2) NOT NULL,
            PRIMARY KEY (customer_id)
);

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

SELECT COUNT(*) FROM olist_customers;

SELECT * FROM olist_customers
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_geolocation
USE olist_data; 

CREATE TABLE olist_geolocation (
            geolocation_zip_code_prefix CHAR(5) NOT NULL,
            geolocation_lat VARCHAR(100) NOT NULL,
            geolocation_lng VARCHAR(100) NOT NULL,
            geolocation_city VARCHAR(100) NOT NULL,
            geolocation_state CHAR(2) NOT NULL,
            PRIMARY KEY (geolocation_zip_code_prefix)
);

TRUNCATE TABLE olist_geolocation;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_geolocation_dataset.csv'
IGNORE # RETIRANDO DUPLICATAS
INTO TABLE olist_geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,geolocation_city,geolocation_state);

SELECT count(*) FROM olist_geolocation;

SELECT * FROM olist_geolocation
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_order_itens
USE olist_data;

CREATE TABLE olist_order_items (
			 order_id VARCHAR(40) NOT NULL,
             order_item_id VARCHAR(40) NOT NULL,
             product_id VARCHAR(40) NOT NULL,
             seller_id VARCHAR(40) NOT NULL,
             shipping_limit_date DATETIME NOT NULL,
             price NUMERIC(12,2) NOT NULL,
             freight_value NUMERIC(12,2) NOT NULL,
			 PRIMARY KEY (order_id,order_item_id,product_id)
);

TRUNCATE TABLE olist_order_itens;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_order_items_dataset.csv'
INTO TABLE olist_order_itens
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value);

SELECT COUNT(*) FROM olist_order_itens;

SELECT * FROM olist_order_itens
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_order_payments
USE olist_data;

CREATE TABLE olist_order_payments (
			 order_id VARCHAR(100) NOT NULL,
             payment_sequential VARCHAR(5) NOT NULL,
             payment_type VARCHAR(40) NOT NULL,
             payment_installments VARCHAR(10) NOT NULL,
             payment_value NUMERIC(30,2),
             PRIMARY KEY (order_id)
);

TRUNCATE TABLE olist_order_payments;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_order_payments_dataset.csv' 
IGNORE
INTO TABLE olist_order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id,payment_sequential,payment_type,payment_installments,payment_value);

SELECT COUNT(*) FROM  olist_order_payments;

SELECT * FROM olist_order_payments
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_order_reviews
USE olist_data;

CREATE TABLE olist_order_reviews (
			 review_id VARCHAR(50) NOT NULL,
             order_id VARCHAR(50) NOT NULL,
             review_score VARCHAR(2) NOT NULL,
             review_comment_title VARCHAR(255) NOT NULL,
             review_comment_message VARCHAR(255) NOT NULL,
             review_creation_date DATETIME NOT NULL,
             review_answer_timestamp DATETIME NOT NULL,
             PRIMARY KEY (review_id,order_id)
);

TRUNCATE TABLE olist_order_reviews;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_order_reviews_dataset.csv' 
INTO TABLE olist_order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(review_id,order_id,review_score,review_comment_title,review_comment_message,review_creation_date,review_answer_timestamp);

SELECT COUNT(*) FROM olist_order_reviews;

SELECT * FROM olist_order_reviews
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_orders
USE olist_data;

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

SELECT COUNT(*) FROM olist_orders;

SELECT * FROM olist_orders
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_products 
USE olist_data;

CREATE TABLE olist_products (
			 product_id VARCHAR(50) NOT NULL,
             product_category_name VARCHAR(100) NOT NULL,
             product_name_lenght VARCHAR(3) NOT NULL,
             product_description_lenght VARCHAR(5) NOT NULL,
             product_photos_qty VARCHAR(5) NOT NULL,
             product_weight_g VARCHAR(5) NOT NULL,
             product_length_cm VARCHAR(5) NOT NULL,
             product_height_cm VARCHAR(5) NOT NULL,
             product_width_cm VARCHAR(5) NOT NULL,
             PRIMARY KEY (product_id)
);

TRUNCATE TABLE olist_products;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_products_dataset.csv' 
INTO TABLE olist_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id,product_category_name,product_name_lenght,product_description_lenght,product_photos_qty,product_weight_g,product_length_cm,product_height_cm,product_width_cm);

SELECT COUNT(*) FROM olist_products;

SELECT * FROM olist_products
LIMIT 10;

-- Criação do banco de dados e importação dos dados: olist_sellers  
USE olist_data;

CREATE TABLE olist_sellers(
			 seller_id VARCHAR(50) NOT NULL,
             seller_zip_code_prefix VARCHAR(5) NOT NULL,
             seller_city VARCHAR(30) NOT NULL,
             seller_state VARCHAR(2) NOT NULL,
             PRIMARY KEY (seller_id)
);

TRUNCATE TABLE olist_sellers;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/olist_sellers_dataset.csv' 
INTO TABLE olist_sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id,seller_zip_code_prefix,seller_city,seller_state);

SELECT COUNT(*) FROM olist_sellers;

SELECT * FROM olist_sellers
LIMIT 10;

-- Criação do banco de dados e importação dos dados: product_category
USE olist_data;

CREATE TABLE product_category (
			 product_category_name VARCHAR(100) NOT NULL,
             product_category_name_english VARCHAR(100) NOT NULL,
             PRIMARY KEY( product_category_name,product_category_name_english)
);

TRUNCATE TABLE product_category;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive/product_category_name_translation.csv' 
INTO TABLE product_category
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_category_name,product_category_name_english);

SELECT COUNT(*) FROM product_category;

SELECT * FROM product_category
LIMIT 10;