-- SABINA COMMENT: Would remove the queries related to the schema,
-- as you already have them in the schema.sql
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

-- SABINA COMMENT: Would also move the cleaning to a different SQL script
-- mainly to help with organizing, readibility.
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
-- SABINA COMMENT: Overall, the analysis follows the right direction, but it lacks comments from you, the analyst! 
-- How am I, a peasant, supposed to understand these numbers without my loyal analyst??? (more specific, big comments below)
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
-- 91508.23000000296

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
-- 'Wicked Choccy\'S','35228.390000000734'
-- 'Lot\'S O\' Nuts','51801.66000000054'


-- most profitable products
SELECT
    `Product Name`,
    SUM(`Gross Profit`) AS total_profit
FROM wonka_choc_factory_clean
GROUP BY `Product Name`
ORDER BY total_profit DESC;
-- SABINA COMMENT: Need to have some conclusions based on these numbers :) (Apply this feedback everywhere else!)
-- For example:
    -- ANALYSIS
    -- We notice that by far the most sold products (top 5) are all Wonka Bar products, exceeding $16K in profits over XX time period.
    -- The next popular product is the Lickable Wallpaper, which falls far behind the Wonka bars, potentially because of less demand / higher price point / recent addition to the inventory.
    -- All remaining products have <$500 in overall profit, thus not being big drivers of the overall profit. 
    -- RECOMMENDATIONS
    -- Diversify Wonka bars to ensure they keep up with consumer trends.
    -- Potentially create limited sales of less popular products that are highly profitable, e.g. Lickable Wallpaper.
-- P.S. Unfortunately having the Total Gross Product per product doesn't tell you which products are most profitable.
-- Why? Because the Total Gross Profit also depends on HOW MANY ITEMS are sold. 
-- To find out what products are the most profitable, you need to look at Gross Margin (Gross Profit / Sales), which is a %. Or you can look at the Profit/Unit, like you did below. Seems I was right about the wallpaper being at a higher price point (and thus higher profit)
-- Technically, Wonka Bars could be the least profitable products (1% margin) but the most sold (16K sold every year).

-- 'Wonka Bar -Scrumdiddlyumptious','18907.5'
-- 'Wonka Bar - Triple Dazzle Caramel','18350.49999999999'
-- 'Wonka Bar - Milk Chocolate','16877.88999999987'
-- 'Wonka Bar - Nutty Crunch Surprise','16593.35999999972'
-- 'Wonka Bar - Fudge Mallows','16300.799999999987'
-- 'Lickable Wallpaper','3790'
-- 'Wonka Gum','310.69999999999993'
-- 'Everlasting Gobstopper','104'
-- 'Kazookles','92.75'
-- 'Hair Toffee','59.5'
-- -- 'Laffy Taffy','33.48'
-- 'Sweetarts','28.700000000000003'
-- 'Fun Dip','4.8'

-- profit per unit 
SELECT
    `Product Name`,
    SUM(`Gross Profit`) / SUM(Units) AS profit_per_unit
FROM wonka_choc_factory_clean
WHERE Units <> 0
GROUP BY `Product Name`
ORDER BY profit_per_unit DESC;
-- 'Lickable Wallpaper','10'
-- 'Everlasting Gobstopper','8'
-- 'Wonka Bar -Scrumdiddlyumptious','2.5'
-- 'Wonka Bar - Nutty Crunch Surprise','2.489999999999958'
-- 'Wonka Bar - Triple Dazzle Caramel','2.4499999999999984'
-- 'Wonka Bar - Fudge Mallows','2.399999999999998'
-- 'Fizzy Lifting Drinks','2.25'
-- 'Wonka Bar - Milk Chocolate','2.1099999999999834'
-- 'Laffy Taffy','1.24'
-- 'Sweetarts','0.7000000000000001'
-- 'Nerds','0.7'
-- 'Wonka Gum','0.6499999999999999'
-- 'Fun Dip','0.6'
-- 'Kazookles','0.25'


-- Products where cost is higher than profit
-- SABINA COMMENT: This is not something that analysts usually look at, because it's very few industries where the Gross Margin is >50% (i.e. profit > cost)
-- You would look at the Gross Profit Margin (%) instead.
SELECT 
    `Product Name`,
    SUM(Cost) AS total_cost,
    SUM(`Gross Profit`) AS total_profit
FROM
    wonka_choc_factory_clean
GROUP BY `Product Name`
HAVING SUM(Cost) > SUM(`Gross Profit`)
ORDER BY total_cost DESC;
		-- total cost/total profit
 -- 'Kazookles','1113','92.75'
-- 'Nerds','8','7'
-- 'Fun Dip','7.2','4.8'

