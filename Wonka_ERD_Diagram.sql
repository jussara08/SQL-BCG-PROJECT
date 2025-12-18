CREATE TABLE `customers` (
  `customer_id` int PRIMARY KEY,
  `country_region` varchar(255),
  `city` varchar(255),
  `state_province` varchar(255),
  `postal_code` varchar(255)
);

CREATE TABLE `products` (
  `product_id` int PRIMARY KEY AUTO_INCREMENT,
  `product_name` varchar(255),
  `division` varchar(255),
  `region` varchar(255),
  `cost` decimal
);

CREATE TABLE `factories` (
  `factory_id` int PRIMARY KEY AUTO_INCREMENT,
  `factory_name` varchar(255),
  `latitude` decimal,
  `longitude` decimal
);

CREATE TABLE `locations` (
  `location_id` int PRIMARY KEY AUTO_INCREMENT,
  `city` varchar(255),
  `state_province` varchar(255),
  `region` varchar(255),
  `country_region` varchar(255)
);

CREATE TABLE `sales` (
  `sale_id` int PRIMARY KEY AUTO_INCREMENT,
  `order_date` date,
  `ship_date` date,
  `ship_mode` varchar(255),
  `customer_id` int,
  `product_id` int,
  `factory_id` int,
  `location_id` int,
  `sales_amount` decimal,
  `units` int,
  `gross_profit` decimal,
  `cost` decimal
);

ALTER TABLE `sales` ADD FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`);

ALTER TABLE `sales` ADD FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

ALTER TABLE `sales` ADD FOREIGN KEY (`factory_id`) REFERENCES `factories` (`factory_id`);

ALTER TABLE `sales` ADD FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`);

USE wonka_choc_factory_clean;
-- CUSTOMERS
INSERT INTO customers (customer_id, country_region, city, state_province, postal_code)
SELECT DISTINCT
    `Customer ID`,
    `Country/Region`,
    City,
    `State/Province`,
    `Postal Code`
FROM wonka_choc_factory_clean;

-- FACTORIES

INSERT INTO factories (factory_name, latitude, longitude)
SELECT DISTINCT
    Factory,
    Latitude,
    Longitude
FROM wonka_choc_factory_clean;
INSERT INTO factories (factory_name, latitude, longitude)
SELECT DISTINCT
    Factory,
    Latitude,
    Longitude
FROM wonka_choc_factory_clean;

SELECT DISTINCT Latitude, Longitude
FROM wonka_choc_factory_clean
LIMIT 10;

-- LOCATIONS

INSERT INTO locations (city, state_province, region, country_region)
SELECT DISTINCT
    City,
    `State/Province`,
    Region,
    `Country/Region`
FROM wonka_choc_factory_clean;

-- PRODUCTS

INSERT INTO products (product_name, division, region, cost)
SELECT DISTINCT
    `Product Name`,
    Division,
    Region,
    Cost
FROM wonka_choc_factory_clean;
-- changing  cost into  decimals
ALTER TABLE products
MODIFY cost DECIMAL(10,2);

-- SALES


INSERT INTO sales (
    order_date, 
    ship_date, 
    ship_mode, 
    customer_id, 
    product_id, 
    factory_id, 
    location_id,
    sales_amount, 
    units, 
    gross_profit, 
    cost
)
SELECT
    w.`Order Date`,
    w.`Ship Date`,
    w.`Ship Mode`,
    c.customer_id,
    p.product_id,
    f.factory_id,
    l.location_id,

    /* CLEAN SALES */
    CASE 
        WHEN w.Sales REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.Sales AS DECIMAL(10,2))
        ELSE NULL
    END AS sales_amount,

    w.Units,

    /* CLEAN GROSS PROFIT */
    CASE 
        WHEN w.`Gross Profit` REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.`Gross Profit` AS DECIMAL(10,2))
        ELSE NULL
    END AS gross_profit,

    /* CLEAN COST */
    CASE 
        WHEN w.Cost REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.Cost AS DECIMAL(10,2))
        ELSE NULL
    END AS cost

FROM wonka_choc_factory_clean w
JOIN customers c ON w.`Customer ID` = c.customer_id
JOIN products p ON w.`Product Name` = p.product_name
JOIN factories f ON w.Factory = f.factory_name
JOIN locations l 
   ON w.City = l.city
  AND w.`State/Province` = l.state_province
  AND w.Region = l.region
  AND w.`Country/Region` = l.country_region;


SELECT Sales
FROM wonka_choc_factory_clean
WHERE Sales NOT REGEXP '^[0-9.+-]+$'
LIMIT 100;

SHOW COLUMNS FROM sales;

ALTER TABLE sales
MODIFY COLUMN sales_amount DECIMAL(15,2),
MODIFY COLUMN gross_profit DECIMAL(15,2),
MODIFY COLUMN cost DECIMAL(15,2);

TRUNCATE TABLE sales;

INSERT INTO sales (
    order_date, 
    ship_date, 
    ship_mode, 
    customer_id, 
    product_id, 
    factory_id, 
    location_id,
    sales_amount, 
    units, 
    gross_profit, 
    cost
)
SELECT
    w.`Order Date`,
    w.`Ship Date`,
    w.`Ship Mode`,
    c.customer_id,
    p.product_id,
    f.factory_id,
    l.location_id,

    /* CLEAN SALES */
    CASE 
        WHEN w.Sales REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.Sales AS DECIMAL(10,2))
        ELSE NULL
    END AS sales_amount,

    w.Units,

    /* CLEAN GROSS PROFIT */
    CASE 
        WHEN w.`Gross Profit` REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.`Gross Profit` AS DECIMAL(10,2))
        ELSE NULL
    END AS gross_profit,

    /* CLEAN COST */
    CASE 
        WHEN w.Cost REGEXP '^[0-9]+(\.[0-9]+)?$'
        THEN CAST(w.Cost AS DECIMAL(10,2))
        ELSE NULL
    END AS cost

FROM wonka_choc_factory_clean w
JOIN customers c ON w.`Customer ID` = c.customer_id
JOIN products p ON w.`Product Name` = p.product_name
JOIN factories f ON w.Factory = f.factory_name
JOIN locations l 
   ON w.City = l.city
  AND w.`State/Province` = l.state_province
  AND w.Region = l.region
  AND w.`Country/Region` = l.country_region;

-- factory profit summary
CREATE VIEW factory_profit_summary AS
SELECT 
    Factory,
    SUM(Sales) AS total_sales,
    SUM(`Gross Profit`) AS total_profit
FROM wonka_choc_factory_clean
GROUP BY factory ;

SELECT * FROM factory_profit_summary;
-- company profit 
SELECT 
    SUM(`Gross Profit`) AS total_company_profit
FROM wonka_choc_factory_clean;

-- comparison of the products
WITH factory_profit AS (
    SELECT 
        Factory,
        SUM(`Gross Profit`) AS total_profit
    FROM wonka_choc_factory_clean
    GROUP BY Factory
) 

SELECT *
FROM factory_profit
WHERE total_profit > (
    SELECT AVG(total_profit) FROM factory_profit
);
-- top 5 more profitable products
SELECT
    `Product Name`,
    SUM(`Gross Profit`) AS total_profit
FROM wonka_choc_factory_clean
GROUP BY `Product Name`
ORDER BY total_profit DESC
LIMIT 5;

-- most profitable products
SELECT
    `Product Name`,
    SUM(`Gross Profit`) AS total_profit
FROM wonka_choc_factory_clean
GROUP BY `Product Name`
ORDER BY total_profit DESC;

-- profit per unit 
SELECT
    `Product Name`,
    SUM(`Gross Profit`) / SUM(Units) AS profit_per_unit
FROM wonka_choc_factory_clean
WHERE Units <> 0
GROUP BY `Product Name`
ORDER BY profit_per_unit DESC;


-- Products where cost is higher than profit
SELECT 
    `Product Name`,
    SUM(Cost) AS total_cost,
    SUM(`Gross Profit`) AS total_profit
FROM
    wonka_choc_factory_clean
GROUP BY `Product Name`
HAVING SUM(Cost) > SUM(`Gross Profit`)
ORDER BY total_cost DESC;
 -- 'Kazookles','1113','92.75'
-- 'Nerds','8','7'
-- 'Fun Dip','7.2','4.8'

