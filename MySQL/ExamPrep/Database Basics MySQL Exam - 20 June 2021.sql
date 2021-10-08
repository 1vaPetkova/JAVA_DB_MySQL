CREATE SCHEMA Exam_20212006;
USE Exam_20212006;

-- 1.	Table Design
CREATE TABLE categories(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(10) NOT NULL
);

CREATE TABLE cars (
id INT PRIMARY KEY AUTO_INCREMENT,
make VARCHAR(20) NOT NULL,
model VARCHAR(20),
year INT NOT NULL,
mileage INT,
`condition` CHAR(1) NOT NULL,
category_id INT NOT NULL,
CONSTRAINT fk_cars_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
);

CREATE TABLE drivers(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
rating FLOAT
);

CREATE TABLE cars_drivers(
car_id INT,
driver_id INT,
PRIMARY KEY (car_id,driver_id),
CONSTRAINT fk_cd_cars
FOREIGN KEY (car_id)
REFERENCES cars(id),
CONSTRAINT fk_cd_drivers
FOREIGN KEY (driver_id)
REFERENCES drivers(id)
);

CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL
);

CREATE TABLE courses(
id INT PRIMARY KEY AUTO_INCREMENT,
from_address_id INT NOT NULL,
`start` DATETIME NOT NULL,
car_id INT NOT NULL,
client_id INT NOT NULL,
bill DECIMAL(10,2),
CONSTRAINT fk_courses_addresses
FOREIGN KEY (from_address_id)
REFERENCES addresses(id),
CONSTRAINT fk_courses_cars
FOREIGN KEY (car_id)
REFERENCES cars(id),
CONSTRAINT fk_courses_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);

-- 2.	Insert
INSERT INTO clients (full_name, phone_number)
SELECT CONCAT(first_name,' ', last_name),
CONCAT('(088) 9999', '', id*2)
FROM drivers AS d
WHERE d.id BETWEEN 10 AND 20;

-- 3.	Update
UPDATE cars
SET `condition` = 'C'
WHERE (mileage >= 800000 OR mileage IS NULL)
AND year <= 2010
AND make NOT IN ('Mercedes-Benz');

-- 4.	Delete
DELETE FROM clients AS c
WHERE c.id NOT IN (SELECT client_id FROM courses)
AND char_length(c.full_name) > 3;

-- 5.	Cars
SELECT make, model, `condition`
FROM cars
ORDER BY id;

-- 6.	Drivers and Cars
SELECT d.first_name, d.last_name, c.make, c.model, c.mileage
FROM drivers AS d
JOIN cars_drivers AS cd ON cd.driver_id = d.id
JOIN cars AS c ON cd.car_id = c.id
WHERE c.mileage IS NOT NULL
ORDER BY c.mileage DESC, d.first_name;

-- 7.	Number of courses for each car
SELECT c.id, c.make, c.mileage, 
IF(c.id NOT IN (SELECT car_id FROM courses),0 , COUNT(c.id)) AS count_of_courses, 
IF(c.id NOT IN (SELECT car_id FROM courses),NULL, ROUND(AVG(co.bill),2)) AS avg_bill
FROM cars AS c
LEFT JOIN courses AS co ON c.id = co.car_id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

-- 8.	Regular clients
SELECT cl.full_name, COUNT(co.car_id) AS count_of_cars, SUM(co.bill) AS total_sum
FROM clients AS cl
JOIN courses AS co ON co.client_id = cl.id
WHERE cl.full_name LIKe '_a%'
GROUP BY cl.id
HAVING count_of_cars > 1
ORDER BY cl.full_name;

-- 9.	Full information of courses
SELECT a.name, 
(CASE 
	WHEN HOUR(co.start) BETWEEN 6 and 20 THEN 'Day'
	ELSE 'Night'
END)
AS day_time, ROUND (co.bill,2) AS bill, cl.full_name, c.make, c.model, ca.name
FROM courses AS co 
JOIN addresses AS a ON a.id = co.from_address_id
JOIN clients AS cl ON cl.id = co.client_id
JOIN cars AS c ON c.id = co.car_id
JOIN categories AS ca ON c.category_id = ca.id
ORDER BY co.id;

-- 10.	Find all courses by client’s phone number
DELIMITER $$
CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20)) 
RETURNS INT DETERMINISTIC
BEGIN
RETURN
(SELECT COUNT(*) 
FROM courses AS co
JOIN clients AS cl ON cl.id = co.client_id
WHERE cl.phone_number = phone_num);
END $$
DELIMITER ;

SELECT udf_courses_by_client ('(803) 6386812') as `count`; 
SELECT udf_courses_by_client ('(831) 1391236') as `count`;
SELECT udf_courses_by_client ('(704) 2502909') as `count`;

-- 11.	Full info for address

DELIMITER $$
CREATE PROCEDURE udp_courses_by_address (address_name VARCHAR(100))
DETERMINISTIC
BEGIN
SELECT a.name, cl.full_name AS full_names,
(
CASE
	WHEN co.bill <= 20 THEN 'Low'
	WHEN co.bill <= 30 THEN 'Medium'
    ELSE 'High'
END
) AS level_of_bill, 
c.make, c.`condition`, ca.name AS cat_name
FROM addresses AS a
JOIN courses AS co ON co.from_address_id = a.id
JOIN clients AS cl ON co.client_id = cl.id
JOIN cars AS c ON co.car_id = c.id
JOIN categories AS ca ON c.category_id = ca.id
WHERE a.name = address_name
ORDER BY c.make, cl.full_name;
END $$

DELIMITER ;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');