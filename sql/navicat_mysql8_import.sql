-- Olist 电商数据导入脚本
-- 适用：MySQL 8.0 + Docker + Navicat
-- CSV 容器内目录：/var/lib/mysql-files/
-- 说明：本脚本使用 LOAD DATA INFILE，不依赖 LOAD DATA LOCAL INFILE。
--       脚本不会删除已有表或数据；重复执行时使用 IGNORE 跳过已存在的主键记录。

CREATE DATABASE IF NOT EXISTS olist
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE olist;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================
-- 1. 用户
-- =========================
CREATE TABLE IF NOT EXISTS customers (
    customer_id CHAR(32) NOT NULL,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix VARCHAR(10) NOT NULL,
    customer_city VARCHAR(100),
    customer_state CHAR(2),
    PRIMARY KEY (customer_id),
    KEY idx_customers_unique_id (customer_unique_id),
    KEY idx_customers_zip (customer_zip_code_prefix)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 2. 地理位置
-- 注意：邮编会重复，因此不设置主键，也不设置自增列。
-- =========================
CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DECIMAL(12,8),
    geolocation_lng DECIMAL(12,8),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2),
    KEY idx_geo_zip (geolocation_zip_code_prefix),
    KEY idx_geo_state (geolocation_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 3. 订单
-- 注意：一个客户可以对应多个订单，customer_id 不能设置唯一约束。
-- =========================
CREATE TABLE IF NOT EXISTS orders (
    order_id CHAR(32) NOT NULL,
    customer_id CHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    PRIMARY KEY (order_id),
    KEY idx_orders_customer_id (customer_id),
    KEY idx_orders_purchase_time (order_purchase_timestamp),
    KEY idx_orders_status (order_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 4. 订单明细
-- =========================
CREATE TABLE IF NOT EXISTS order_items (
    order_id CHAR(32) NOT NULL,
    order_item_id INT NOT NULL,
    product_id CHAR(32),
    seller_id CHAR(32),
    shipping_limit_date DATETIME,
    price DECIMAL(12,2),
    freight_value DECIMAL(12,2),
    PRIMARY KEY (order_id, order_item_id),
    KEY idx_items_product_id (product_id),
    KEY idx_items_seller_id (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 5. 订单支付
-- =========================
CREATE TABLE IF NOT EXISTS order_payments (
    order_id CHAR(32) NOT NULL,
    payment_sequential INT NOT NULL,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(12,2),
    PRIMARY KEY (order_id, payment_sequential),
    KEY idx_payments_type (payment_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 6. 订单评价
-- 不强制设置 review_id 主键，避免历史数据中的重复评价编号导致导入失败。
-- =========================
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id CHAR(32),
    order_id CHAR(32),
    review_score TINYINT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    KEY idx_reviews_order_id (order_id),
    KEY idx_reviews_score (review_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 7. 商品
-- =========================
CREATE TABLE IF NOT EXISTS products (
    product_id CHAR(32) NOT NULL,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    PRIMARY KEY (product_id),
    KEY idx_products_category (product_category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 8. 卖家
-- =========================
CREATE TABLE IF NOT EXISTS sellers (
    seller_id CHAR(32) NOT NULL,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state CHAR(2),
    PRIMARY KEY (seller_id),
    KEY idx_sellers_zip (seller_zip_code_prefix),
    KEY idx_sellers_state (seller_state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 9. 商品分类翻译
-- =========================
CREATE TABLE IF NOT EXISTS product_category_translation (
    product_category_name VARCHAR(100) NOT NULL,
    product_category_name_english VARCHAR(100),
    PRIMARY KEY (product_category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 10. 营销合格线索
-- =========================
CREATE TABLE IF NOT EXISTS marketing_qualified_leads (
    mql_id CHAR(32) NOT NULL,
    first_contact_date DATE,
    landing_page_id CHAR(32),
    origin VARCHAR(100),
    PRIMARY KEY (mql_id),
    KEY idx_mql_origin (origin),
    KEY idx_mql_contact_date (first_contact_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- 11. 成交线索
-- =========================
CREATE TABLE IF NOT EXISTS closed_deals (
    mql_id CHAR(32),
    seller_id CHAR(32),
    sdr_id CHAR(32),
    sr_id CHAR(32),
    won_date DATETIME,
    business_segment VARCHAR(100),
    lead_type VARCHAR(100),
    business_type VARCHAR(100),
    declared_product_catalog_size DECIMAL(12,2),
    declared_monthly_revenue DECIMAL(14,2),
    KEY idx_closed_mql_id (mql_id),
    KEY idx_closed_seller_id (seller_id),
    KEY idx_closed_won_date (won_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =========================
-- CSV 导入
-- =========================
-- 容器启动参数需要将宿主机目录绑定到：
-- /var/lib/mysql-files/
-- 例如：/root/olist_data:/var/lib/mysql-files
-- 文件必须位于 MySQL 容器内的 /var/lib/mysql-files/ 目录。

LOAD DATA INFILE '/var/lib/mysql-files/olist_customers_dataset.csv'
IGNORE INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@customer_id, @customer_unique_id, @zip, @city, @state)
SET customer_id = NULLIF(TRIM(@customer_id), ''),
    customer_unique_id = NULLIF(TRIM(@customer_unique_id), ''),
    customer_zip_code_prefix = NULLIF(TRIM(@zip), ''),
    customer_city = NULLIF(TRIM(@city), ''),
    customer_state = NULLIF(TRIM(@state), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@zip, @lat, @lng, @city, @state)
SET geolocation_zip_code_prefix = NULLIF(TRIM(@zip), ''),
    geolocation_lat = NULLIF(TRIM(@lat), ''),
    geolocation_lng = NULLIF(TRIM(@lng), ''),
    geolocation_city = NULLIF(TRIM(@city), ''),
    geolocation_state = NULLIF(TRIM(@state), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_orders_dataset.csv'
IGNORE INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@order_id, @customer_id, @status, @purchase, @approved, @carrier, @delivered, @estimated)
SET order_id = NULLIF(TRIM(@order_id), ''),
    customer_id = NULLIF(TRIM(@customer_id), ''),
    order_status = NULLIF(TRIM(@status), ''),
    order_purchase_timestamp = STR_TO_DATE(NULLIF(TRIM(@purchase), ''), '%Y-%m-%d %H:%i:%s'),
    order_approved_at = STR_TO_DATE(NULLIF(TRIM(@approved), ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_carrier_date = STR_TO_DATE(NULLIF(TRIM(@carrier), ''), '%Y-%m-%d %H:%i:%s'),
    order_delivered_customer_date = STR_TO_DATE(NULLIF(TRIM(@delivered), ''), '%Y-%m-%d %H:%i:%s'),
    order_estimated_delivery_date = STR_TO_DATE(NULLIF(TRIM(@estimated), ''), '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE '/var/lib/mysql-files/olist_order_items_dataset.csv'
IGNORE INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@order_id, @item_id, @product_id, @seller_id, @shipping_limit, @price, @freight)
SET order_id = NULLIF(TRIM(@order_id), ''),
    order_item_id = NULLIF(TRIM(@item_id), ''),
    product_id = NULLIF(TRIM(@product_id), ''),
    seller_id = NULLIF(TRIM(@seller_id), ''),
    shipping_limit_date = STR_TO_DATE(NULLIF(TRIM(@shipping_limit), ''), '%Y-%m-%d %H:%i:%s'),
    price = NULLIF(TRIM(@price), ''),
    freight_value = NULLIF(TRIM(@freight), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_order_payments_dataset.csv'
IGNORE INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@order_id, @seq, @type, @installments, @value)
SET order_id = NULLIF(TRIM(@order_id), ''),
    payment_sequential = NULLIF(TRIM(@seq), ''),
    payment_type = NULLIF(TRIM(@type), ''),
    payment_installments = NULLIF(TRIM(@installments), ''),
    payment_value = NULLIF(TRIM(@value), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@review_id, @order_id, @score, @title, @message, @created, @answered)
SET review_id = NULLIF(TRIM(@review_id), ''),
    order_id = NULLIF(TRIM(@order_id), ''),
    review_score = NULLIF(TRIM(@score), ''),
    review_comment_title = NULLIF(TRIM(@title), ''),
    review_comment_message = NULLIF(TRIM(@message), ''),
    review_creation_date = STR_TO_DATE(NULLIF(TRIM(@created), ''), '%Y-%m-%d %H:%i:%s'),
    review_answer_timestamp = STR_TO_DATE(NULLIF(TRIM(@answered), ''), '%Y-%m-%d %H:%i:%s');

LOAD DATA INFILE '/var/lib/mysql-files/olist_products_dataset.csv'
IGNORE INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@product_id, @category, @name_len, @desc_len, @photos, @weight, @length, @height, @width)
SET product_id = NULLIF(TRIM(@product_id), ''),
    product_category_name = NULLIF(TRIM(@category), ''),
    product_name_lenght = NULLIF(TRIM(@name_len), ''),
    product_description_lenght = NULLIF(TRIM(@desc_len), ''),
    product_photos_qty = NULLIF(TRIM(@photos), ''),
    product_weight_g = NULLIF(TRIM(@weight), ''),
    product_length_cm = NULLIF(TRIM(@length), ''),
    product_height_cm = NULLIF(TRIM(@height), ''),
    product_width_cm = NULLIF(TRIM(@width), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_sellers_dataset.csv'
IGNORE INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@seller_id, @zip, @city, @state)
SET seller_id = NULLIF(TRIM(@seller_id), ''),
    seller_zip_code_prefix = NULLIF(TRIM(@zip), ''),
    seller_city = NULLIF(TRIM(@city), ''),
    seller_state = NULLIF(TRIM(@state), '');

LOAD DATA INFILE '/var/lib/mysql-files/product_category_name_translation.csv'
IGNORE INTO TABLE product_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@category, @english)
SET product_category_name = NULLIF(TRIM(@category), ''),
    product_category_name_english = NULLIF(TRIM(@english), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_marketing_qualified_leads_dataset.csv'
IGNORE INTO TABLE marketing_qualified_leads
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@mql_id, @contact_date, @landing_page, @origin)
SET mql_id = NULLIF(TRIM(@mql_id), ''),
    first_contact_date = STR_TO_DATE(NULLIF(TRIM(@contact_date), ''), '%Y-%m-%d'),
    landing_page_id = NULLIF(TRIM(@landing_page), ''),
    origin = NULLIF(TRIM(@origin), '');

LOAD DATA INFILE '/var/lib/mysql-files/olist_closed_deals_dataset.csv'
INTO TABLE closed_deals
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@mql_id, @seller_id, @sdr_id, @sr_id, @won_date, @segment, @lead_type, @business_type, @catalog_size, @monthly_revenue)
SET mql_id = NULLIF(TRIM(@mql_id), ''),
    seller_id = NULLIF(TRIM(@seller_id), ''),
    sdr_id = NULLIF(TRIM(@sdr_id), ''),
    sr_id = NULLIF(TRIM(@sr_id), ''),
    won_date = STR_TO_DATE(NULLIF(TRIM(@won_date), ''), '%Y-%m-%d %H:%i:%s'),
    business_segment = NULLIF(TRIM(@segment), ''),
    lead_type = NULLIF(TRIM(@lead_type), ''),
    business_type = NULLIF(TRIM(@business_type), ''),
    declared_product_catalog_size = NULLIF(TRIM(@catalog_size), ''),
    declared_monthly_revenue = NULLIF(TRIM(@monthly_revenue), '');

SET FOREIGN_KEY_CHECKS = 1;

-- =========================
-- 导入后核验
-- =========================
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM product_category_translation
UNION ALL SELECT 'marketing_qualified_leads', COUNT(*) FROM marketing_qualified_leads
UNION ALL SELECT 'closed_deals', COUNT(*) FROM closed_deals;

