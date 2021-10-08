CREATE SCHEMA db_201018;
USE db_201018;

-- 1.	Table Design
CREATE TABLE pictures(
id INT PRIMARY KEY AUTO_INCREMENT,
url VARCHAR (100) NOT NULL,
added_on DATETIME NOT NULL
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL
);

CREATE TABLE products (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
best_before DATE, 
price DECIMAL(10,2) NOT NULL,
description TEXT,
category_id INT NOT NULL,
picture_id INT NOT NULL,
CONSTRAINT fk_products_pictures
FOREIGN KEY (picture_id)
REFERENCES pictures(id),
CONSTRAINT fk_products_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(20) NOT NULL
);

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
town_id INT NOT NULL,
CONSTRAINT fk_addresses_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE stores(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(20) NOT NULL,
rating FLOAT NOT NULL,
has_parking TINYINT(1),
address_id INT NOT NULL,
CONSTRAINT fk_stores_addresses
FOREIGN KEY (address_id)
REFERENCES addresses(id)
);

CREATE TABLE products_stores (
product_id INT,
store_id INT,
PRIMARY KEY (product_id, store_id),
CONSTRAINT fk_ps_products
FOREIGN KEY (product_id)
REFERENCES products(id),
CONSTRAINT fk_ps_stores
FOREIGN KEY (store_id)
REFERENCES stores(id)
);

CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(15) NOT NULL,
middle_name CHAR,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(19,2) NOT NULL,
hire_date DATE NOT NULL,
manager_id INT,
store_id INT NOT NULL,
CONSTRAINT fk_employees_managers
FOREIGN KEY (manager_id)
REFERENCES employees(id),
CONSTRAINT fk_employees_strore
FOREIGN KEY (store_id)
REFERENCES stores(id)
);

-- 2.	Insert
INSERT INTO products_stores (product_id, store_id)
SELECT p.id, 1 
FROM products AS p
WHERE (SELECT COUNT(*) FROM products_stores WHERE p.id = product_id) = 0;

-- 3.	Update
UPDATE employees AS e
SET e.manager_id = 3, e.salary = e.salary - 500
WHERE YEAR(e.hire_date) > '2003'
AND e.store_id NOT IN (
SELECT s.id
FROM stores AS s
WHERE s.name IN ('Cardguard', 'Veribet') 
);


-- 4.	Delete
DELETE FROM employees AS e
WHERE e.manager_id IS NOT NULL
AND e.salary >= 6000;

-- 5.	Employees 
SELECT first_name, middle_name, last_name, salary, hire_date
FROM employees
ORDER BY hire_date DESC;

-- 6.	Products with old pictures
SELECT p.name AS product_name, p.price, p.best_before, 
CONCAT(LEFT (p.description,10),'','...') AS short_description, 
pic.url
FROM products AS p
JOIN pictures AS pic
ON p.picture_id = pic.id
WHERE char_length(p.description) > 100
AND YEAR(pic.added_on) < '2019'
AND p.price > 20
ORDER BY p.price DESC;

-- 7.	Counts of products in stores and their average 
SELECT s.name, (SELECT COUNT(*) FROM products_stores WHERE s.id = store_id) AS product_count, 
ROUND ( 
(SELECT AVG(p_2.price)  FROM products  AS p_2
LEFT JOIN products_stores AS ps_2
ON p_2.id = ps_2.product_id
WHERE ps_2.store_id = s.id)
,2) AS `avg`
FROM stores AS s
LEFT JOIN products_stores AS ps
ON ps.store_id = s.id
GROUP BY s.name
ORDER BY product_count DESC, `avg` DESC, s.id;

-- 8.	Specific employee
SELECT CONCAT_WS(' ', e.first_name, e.last_name) AS Full_name,
s.name AS Store_name, a.name AS address, e.salary
FROM employees AS e
JOIN stores AS s
ON s.id = e.store_id
JOIN addresses AS a
ON s.address_id = a.id
WHERE e.salary < 4000
AND a.name LIKE '%5%'
AND char_length(s.name) > 8
AND e.last_name LIKE '%n';

-- 9.	Find all information of stores
SELECT REVERSE(s.name) AS reversed_name, CONCAT(UPPER(t.name),'-', a.name) AS full_address, 
(SELECT COUNT(*) FROM employees WHERE store_id = s.id) AS employees_count
FROM stores AS s
JOIN addresses AS a
ON s.address_id = a.id
JOIN towns as t
ON a.town_id = t.id
HAVING employees_count >= 1
ORDER BY full_address;

-- 10.	Find full name of top paid employee by store name
DELIMITER $$

CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS TEXT DETERMINISTIC
BEGIN
RETURN(
SELECT CONCAT(
e.first_name,' ',
e.middle_name,'. ',
e.last_name,
' works in store for ', 
(YEAR('2020-10-18')-YEAR(hire_date)),
' years') AS full_info
FROM employees AS e
JOIN stores AS s
ON e.store_id = s.id
WHERE s.name = store_name 
AND e.salary = (SELECT MAX(salary) FROM employees WHERE s.id = store_id));
END $$

DELIMITER ;
SELECT udf_top_paid_employee_by_store('Stronghold') AS full_info;
SELECT udf_top_paid_employee_by_store('Keylex') AS full_info;

-- 11.	Update product price by address
DELIMITER $$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
UPDATE products AS p
JOIN products_stores as ps
ON p.id = ps.product_id
JOIN stores AS s
ON s.id = ps.store_id
JOIN addresses AS a
ON a.id = s.address_id
SET p.price =  IF (a.name LIKE '0%', p.price + 100, p.price + 200)
WHERE a.name = address_name;
END $$
 
DELIMITER ;

CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;
 