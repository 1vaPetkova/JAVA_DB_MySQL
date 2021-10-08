CREATE DATABASE `minions`;
USE `minions`;

-- P01 Create Tables
CREATE TABLE `minions`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
`age` INT 
);

CREATE TABLE `towns`(
`town_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) NOT NULL
);

-- P02 Alter Minions Table
SELECT * FROM `minions`;
ALTER TABLE `minions`
ADD COLUMN `town_id` INT,
ADD CONSTRAINT fk_minions_towns
FOREIGN KEY (`town_id`)
REFERENCES `towns` (`id`);

-- P03 Insert Records in Both Tables
INSERT INTO `towns` (`id`,`name`)
VALUES 
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna');

INSERT INTO `minions` (`name`,`age`,`town_id`)
VALUES 
('Kevin',22,1),
('Bob',15,3),
('Steward',NULL,2);

-- P04 Truncate Table Minions
TRUNCATE `minions`;

-- P05 Drop All Tables
DROP TABLE `minions`;
DROP TABLE `towns`;

-- P06 Create Table People
CREATE TABLE `people`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` MEDIUMBLOB ,
`height` DECIMAL(5,2),
`weight` DECIMAL(5,2) ,
`gender` ENUM('m','f') NOT NULL,
`birthdate` DATE NOT NULL,
`biography` TEXT);
 
 INSERT INTO `people`(`name`,`picture`,`height`,`weight`,`gender`,`birthdate`,`biography`) 
VALUES ('Pesho Peshov',NULL,NULL,NULL,'m','1995-02-11',''),
('Sasho Sashov',NULL,NULL,1.72,'m','1987-06-01',''),
('Toshka Toshkova',NULL,1.75,66,'f','1991-02-18',NULL),
('Sevda Sevdova',NULL,1.66,62,'f','1988-07-16','Until last year she was a signer'),
('Gosho Goshov',NULL,NULL,NULL,'m','1991-08-29',NULL);

-- P07 Create Table Users
CREATE TABLE `users`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`username` VARCHAR(30) NOT NULL,
`password` VARCHAR(26) NOT NULL,
`profile_picture` BLOB,
`last_login_time` DATETIME,
`is_deleted` ENUM('true','false'));

INSERT INTO `users`(`username`,`password`,`profile_picture`,`last_login_time`,`is_deleted`) 
			VALUES ('Pesho Peshov','iampesho123',NULL,'2021-09-21 21:30','false'),
					('Kira_5','chichi',NULL,'2021-09-21 21:30','true'),
					('Sasheto','passswooord',NULL,'2021-08-24 16:20','false'),
					('Elito','kotekote',NULL,NULL,'true'),
					('PatePate','patepass',NULL,'2021-09-24 00:20','false');
                    
-- P08 Change Primary Key
 ALTER TABLE `users`   
 DROP PRIMARY KEY,
 ADD CONSTRAINT pk_users PRIMARY KEY(`id`,`username`);
 
 -- P09 Set Default Value of a Field
ALTER TABLE `users` 
	MODIFY COLUMN `last_login_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP; -- now()


 -- P10 Set Unique Field
ALTER TABLE `users`  
DROP PRIMARY KEY,
ADD CONSTRAINT pk_users PRIMARY KEY(`id`),
ADD CONSTRAINT UNIQUE (`username`);


ALTER TABLE `users`
CHANGE `username` `username` VARCHAR(30) UNIQUE;
      
-- P11 Movies Database
CREATE SCHEMA `Movies`;
USE `Movies`;
CREATE TABLE `directors`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`director_name` VARCHAR(45) NOT NULL,
`notes` TEXT
);

INSERT INTO `directors`(`director_name`,`notes`)
VALUES ('Pesho Peshov',NULL),
('Gosho Goshov', NULL),
('Sasho Sashov', NULL),
('Tosho Toshov', NULL),
('Kiro Kirov', NULL);

CREATE TABLE `genres`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`genre_name` VARCHAR(15) NOT NULL,
`notes` TEXT
);

INSERT INTO `genres`(`genre_name`,`notes`)
VALUES ('Comedy',NULL),
('Action',NULL),
('Romance',NULL),
('Horror',NULL),
('Animation',NULL);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`category_name` VARCHAR(15) NOT NULL,
`notes` TEXT
);

INSERT INTO `categories`(`category_name`,`notes`)
VALUES ('Best Feature', NULL),
('Best Actor', NULL),
('Best Director', NULL),
('Best Actress', NULL),
('Best Costumes', NULL);

CREATE TABLE `movies`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`title` VARCHAR(45) NOT NULL,
`director_id` INT NOT NULL,
`copyright_year` YEAR,
`length` VARCHAR(50),
`genre_id` INT NOT NULL,
`category_id` INT NOT NULL,
`rating` VARCHAR(50),
`notes` TEXT
);

INSERT INTO `movies` 
VALUES (1, 'Saving Private Ryan', 1, '1999', '130 min', 5, 1, '', NULL),
(2, 'Gone Girl', 2, '2016', '134 min', 3, 2, '', NULL),
(3, 'Gladiator', 3, '2000', '120 min', 2, 3, '', NULL),
(4, 'Intersteller', 4, '2015', '128 min', 4, 5, '', NULL),
(5, 'Erin Brokovich', 5, '1998', '140 min', 1, 4, '', NULL);   
                                        
-- P12 Car Rental Database
CREATE SCHEMA `car_rental`;
USE `car_rental`;
CREATE TABLE `categories`(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
category VARCHAR(30) NOT NULL,
daily_rate DECIMAL(6,2) NOT NULL,
weekly_rate DECIMAL(6,2) NOT NULL,
monthly_rate DECIMAL(7,2) NOT NULL,
weekend_rate DECIMAL(6,2) NOT NULL);

CREATE TABLE cars(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
plate_number VARCHAR(20) NOT NULL UNIQUE,
make VARCHAR(30) NOT NULL,
model VARCHAR(30) NOT NULL,
car_year YEAR,
category_id INT NOT NULL,
doors INT,
picture MEDIUMBLOB,
car_condition TEXT,
available BIT NOT NULL);

CREATE TABLE employees(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
title VARCHAR(50) NOT NULL,
notes TEXT);

CREATE TABLE customers(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
driver_licence_number VARCHAR(30) NOT NULL,
full_name VARCHAR(50) NOT NULL,
address VARCHAR(100) NOT NULL,
city VARCHAR(30) NOT NULL,
zip_code VARCHAR(50) NOT NULL,
notes TEXT);

CREATE TABLE rental_orders(
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
employee_id INT NOT NULL,
customer_id INT NOT NULL,
car_id INT NOT NULL,
car_condition VARCHAR(50),
tank_level INT,
kilometrage_start INT,
kilometrage_end INT,
total_kilometrage INT,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
total_days INT,
rate_applied ENUM('daily_rate', 'weekly_rate', 'monthly_rate', 'weekend_rate') NOT NULL,
tax_rate DECIMAL(5, 2) NOT NULL,
order_status TEXT,
notes TEXT);

INSERT INTO `categories`(category, daily_rate, weekly_rate, monthly_rate, weekend_rate)
VALUES ('first', 3, 20, 70, 5),
('second', 4, 22, 80, 7),
('third', 5, 31, 115, 9);

INSERT INTO cars(plate_number, make, model, category_id, available)
VALUES ('SX555', 'Mercedes', 'S-class', 2, true),
('somenum', 'Mercedes', 'G-class', 2, false),
('anothernum', 'Mercedes', 'S-class', 2, false);

INSERT INTO employees(first_name, last_name, title)
VALUES ('Pesho', 'Peshov', 'Boss'),
('name', 'name', 'title'),
('name2', 'name2', 'title2');

INSERT INTO customers(driver_licence_number, full_name, address, city, zip_code)
VALUES (9393938, 'Pesho Peshov', 'address', 'sofia', 'code'),
(929393, 'Pesho Peshov', 'address', 'sofia', 'code'),
(939393438, 'Pesho Peshov', 'address', 'sofia', 'code');

INSERT INTO rental_orders(employee_id, customer_id, car_id, start_date, end_date, rate_applied, tax_rate)
VALUES (1, 2, 1, '2018-01-02', '2018-01-07', 'daily_rate', 0.2),
(1, 1, 2, '2018-01-02', '2018-01-09', 'weekly_rate', 0.2),
(1, 2, 3, '2018-01-02', '2018-02-02', 'monthly_rate', 0.2);
                           
-- P13 Hotel Database
CREATE DATABASE `hotel`;
USE `hotel`;

CREATE TABLE `employees` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`first_name` VARCHAR(30) NOT NULL,
	`last_name` VARCHAR(30) NOT NULL,
	`title` VARCHAR(30) NOT NULL,
	`notes` VARCHAR(128)
);

INSERT INTO `employees`
		(`first_name`, `last_name`, `title`, `notes`)
	VALUES 
		('Gosho', 'Goshev', 'Boss', ''),
		('Pesho', 'Peshev', 'Supervisor', ''),
		('Bai', 'Ivan', 'Worker', 'Can do any work');

CREATE TABLE `customers` (
	`account_number` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`first_name` VARCHAR(30) NOT NULL,
	`last_name` VARCHAR(30) NOT NULL,
	`phone_number` VARCHAR(20) NOT NULL,
	`emergency_name` VARCHAR(50),
	`emergency_number` VARCHAR(20),
	`notes` VARCHAR(128)
);

INSERT INTO `customers`
		(`first_name`, `last_name`, `phone_number`)
	VALUES 
		('Gosho', 'Goshev', '123'),
		('Pesho', 'Peshev', '44-2432'),
		('Bai', 'Ivan', '007');

CREATE TABLE `room_status` (
	`room_status` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `room_status` 
		(`notes`)
	VALUES 
		('Free'),
		('For clean'),
		('Occupied');

CREATE TABLE `room_types` (
	`room_type` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `room_types` 
		(`notes`)
	VALUES 
		('Small'),
		('Medium'),
		('Appartment');


CREATE TABLE `bed_types` (
	`bed_type` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `bed_types` 
		(`notes`)
	VALUES 
		('Single'),
		('Double'),
		('Water-filled');

CREATE TABLE `rooms` (
	`room_number` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`room_type` INT UNSIGNED NOT NULL,
	`bed_type` INT UNSIGNED NOT NULL,
	`rate` DOUBLE DEFAULT 0,
	`room_status` INT UNSIGNED NOT NULL,
	`notes` VARCHAR(128)
);

INSERT INTO `rooms` 
		(`room_type`, `bed_type`, `room_status`)
	VALUES 
		(1, 1, 1),
		(2, 2, 2),
		(3, 3, 3);

CREATE TABLE `payments` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`employee_id` INT UNSIGNED NOT NULL,
	`payment_date` DATE NOT NULL,
	`account_number` INT UNSIGNED NOT NULL,
	`first_date_occupied` DATE,
	`last_date_occupied` DATE,
	`total_days` INT UNSIGNED,
	`amount_charged` DOUBLE,
	`tax_rate` DOUBLE,
	`tax_amount` DOUBLE,
	`payment_total` DOUBLE,
	`notes` VARCHAR(128)
);

INSERT INTO `payments` 
		(`employee_id`, `payment_date`, `account_number`)
	VALUES 
		(1, DATE(NOW()), 1),
		(2, DATE(NOW()), 2),
		(3, DATE(NOW()), 3);


CREATE TABLE `occupancies` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`employee_id` INT UNSIGNED NOT NULL,
	`date_occupied` DATE NOT NULL,
	`account_number` INT UNSIGNED NOT NULL,
	`room_number` INT UNSIGNED NOT NULL,
	`rate_applied` DOUBLE,
	`phone_charge` DOUBLE,
	`notes` VARCHAR(128)
);

INSERT INTO `occupancies` 
		(`employee_id`, `date_occupied`, `account_number`, `room_number`)
	VALUES 
		(1, DATE(NOW()), 1, 1),
		(2, DATE(NOW()), 2, 2),
		(3, DATE(NOW()), 3, 3);
  
-- P14 Basic Insert
CREATE DATABASE `soft_uni`;
USE `soft_uni`;

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) );

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`address_text` VARCHAR(45),
`town_id` INT, 
CONSTRAINT fk_addresses_towns
FOREIGN KEY(`town_id`)
REFERENCES `towns`(`id`)
);

CREATE TABLE `departments`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) 
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`middle_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`job_title` VARCHAR(45) NOT NULL,
`department_id` INT  NOT NULL,
`hire_date` DATE  NOT NULL,
`salary` DECIMAL(15,2)  NOT NULL,
`address_id` INT,
CONSTRAINT fk_employees_departments
FOREIGN KEY(`department_id`)
REFERENCES `departments`(`id`),
CONSTRAINT fk_employees_addresses
FOREIGN KEY(`address_id`)
REFERENCES `addresses`(`id`)
);

INSERT INTO `towns`(`name`) 
VALUES 	('Sofia'),
		('Plovdiv'),
		('Varna'),
		('Burgas');
        
INSERT INTO `departments`(`name`)
VALUES 	('Engineering'),
		('Sales'),
		('Marketing'),
		('Software Development'),
		('Quality Assurance');
        
 INSERT INTO `employees` 
		(`first_name`,`middle_name`,`last_name`,`job_title`,`department_id`,`hire_date`,`salary`)
 VALUES ('Ivan','Ivanov','Ivanov','.NET Developer', 4,'2013-02-01', 3500.00),
		('Petar','Petrov','Petrov','Senior Engineer', 1,'2004-03-02', 4000.00),
		('Maria','Petrova','Ivanova','Intern', 5,'2016-08-28', 525.25),
		('Georgi','Terziev','Ivanov','CEO', 2,'2007-12-09', 3000.00),
		('Peter','Pan','Pan','Intern', 3,'2016-08-28', 599.88);
        
-- P15 Basic Select All Fields
USE `soft_uni`;
SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;

-- P16 Basic Select All Fields and Order Them
SELECT * FROM `towns` ORDER BY `name`;
SELECT * FROM `departments` ORDER BY `name`;
SELECT * FROM `employees` ORDER BY `salary` DESC;

-- P17	Basic Select Some Fields
SELECT `name` FROM `towns` ORDER BY `name`;
SELECT `name` FROM `departments` ORDER BY `name`;
SELECT `first_name`,`last_name`,`job_title`,`salary` FROM `employees` ORDER BY `salary` DESC;

-- P18	Increase Employees Salary
UPDATE `employees` 
SET `salary` = `salary` * 1.1;
SELECT `salary` FROM `employees`;

-- 19. Decrease Tax Rate
UPDATE `payments` 
SET `tax_rate` = `tax_rate` * 0.97;

SELECT `tax_rate` FROM `payments`;

-- 20 Delete All Records
DELETE FROM `occupancies`;