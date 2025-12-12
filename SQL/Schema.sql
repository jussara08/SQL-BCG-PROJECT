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
