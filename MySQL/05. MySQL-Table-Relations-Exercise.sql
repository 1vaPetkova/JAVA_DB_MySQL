-- Exercise
CREATE SCHEMA ex05;
USE  ex05;
-- 1.	One-To-One Relationship
CREATE TABLE `passports`(
`passport_id` INT PRIMARY KEY AUTO_INCREMENT,
`passport_number` VARCHAR(45) NOT NULL
);

ALTER TABLE `passports` AUTO_INCREMENT = 101;
INSERT INTO `passports` (`passport_number`)
VALUES	('N34FG21B'),
		('K65LO4R7'),
		('ZE657QP2');
        
CREATE TABLE `people`(
`person_id` INT PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR(45) NOT NULL,
`salary` DECIMAL (7,2),
`passport_id` INT NOT NULL UNIQUE,
CONSTRAINT `fk_people_passports`
FOREIGN KEY (`passport_id`)
REFERENCES `passports`(`passport_id`)
);

INSERT INTO `people` 
VALUES (1,'Roberto', 43300.00,102),
		(2,'Tom', 56100.00,103),
		(3,'Yana', 60200.00,101);

-- 2.	One-To-Many Relationship
CREATE TABLE `manufacturers`(
`manufacturer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL,
`established_on` DATE
);

INSERT INTO `manufacturers`
VALUES (1,'BMW','1916/03/01'),
 (2,'Tesla','2003/01/01'),
 (3,'Lada','1966/05/01');
 
 CREATE TABLE `models`(
`model_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (45) NOT NULL,
`manufacturer_id` INT,
CONSTRAINT `fk_models_manufacturer`
FOREIGN KEY (`manufacturer_id`)
REFERENCES `manufacturers`(`manufacturer_id`)
);

INSERT INTO `models`
VALUES (101,'X1',1),
	(102,'i6',1),
	(103,'Model S',2),
	(104,'Model X',2),
	(105,'Model 3',2),
	(106,'Nova',3);
    
-- 3.	Many-To-Many Relationship
CREATE TABLE `students`(
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

INSERT INTO `students`
VALUES	(1,'Mila'),
		(2,'Toni'),
		(3,'Ron');

CREATE TABLE `exams`(
`exam_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

INSERT INTO `exams`
VALUES	(101,'Spring MVC'),
		(102,'Neo4j'),
		(103,'Oracle 11g');

CREATE TABLE `students_exams`(
`student_id` INT NOT NULL,
`exam_id` INT NOT NULL,
PRIMARY KEY (`student_id`,`exam_id`)
);

ALTER TABLE `students_exams`
ADD CONSTRAINT `fk_se_students`
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`),
ADD CONSTRAINT `fk_se_exams`
FOREIGN KEY (`exam_id`)
REFERENCES `exams`(`exam_id`);

INSERT INTO `students_exams`
VALUES	(1,101),
		(1,102),
		(2,101),
		(3,103),
		(2,102),
		(2,103);
        
-- 4.	Self-Referencing
CREATE TABLE `teachers`(
`teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (20),
`manager_id` INT
);

INSERT INTO `teachers` VALUES
(101, 'John',NULL),
(102, 'Maya',106),
(103, 'Silvia',106),
(104, 'Ted',105),
(105, 'Mark',101),
(106, 'Greta',101);

ALTER TABLE `teachers`
ADD CONSTRAINT `fk_teachers_managers`
FOREIGN KEY (`manager_id`)
REFERENCES `teachers` (`teacher_id`);

-- 5.	Online Store Database
CREATE SCHEMA `online_store`;
USE `online_store`;

CREATE TABLE `item_types`(
`item_type_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

CREATE TABLE `cities`(
`city_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50)
);

CREATE TABLE `customers`(
`customer_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`birthday` DATE,
`city_id` INT,
CONSTRAINT `fk_customers_cities`
FOREIGN KEY (`city_id`)
REFERENCES `cities`(`city_id`)
);

CREATE TABLE `items`(
`item_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50),
`item_type_id` INT,
CONSTRAINT `fk_items_item_types`
FOREIGN KEY (`item_type_id`)
REFERENCES `item_types`(`item_type_id`)
);

CREATE TABLE `orders`(
`order_id` INT PRIMARY KEY AUTO_INCREMENT,
`customer_id` INT ,
CONSTRAINT `fk_customers_orders`
FOREIGN KEY (`customer_id`)
REFERENCES `customers`(`customer_id`)
);

CREATE TABLE `order_items`(
`order_id` INT,
`item_id` INT,
PRIMARY KEY (`order_id`,`item_id`),
CONSTRAINT `fk_oi_orders`
FOREIGN KEY (`order_id`)
REFERENCES `orders`(`order_id`),
CONSTRAINT `fk_oi_items`
FOREIGN KEY (`item_id`)
REFERENCES `items`(`item_id`)
);

-- 6.	University Database
CREATE SCHEMA `university_database`;
USE `university_database`;

CREATE TABLE `subjects`(
`subject_id` INT PRIMARY KEY AUTO_INCREMENT,
`subject_name` VARCHAR (50)
);

CREATE TABLE `majors`(
`major_id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR (50)
);

CREATE TABLE `students` (
`student_id` INT PRIMARY KEY AUTO_INCREMENT,
`student_number` VARCHAR(12),
`student_name` VARCHAR (50),
`major_id` INT,
CONSTRAINT `fk_students_majors`
FOREIGN KEY (`major_id`)
REFERENCES `majors`(`major_id`)
);

CREATE TABLE `payments`(
`payment_id` INT PRIMARY KEY AUTO_INCREMENT,
`payment_date` DATE,
`payment_amount` DECIMAL (8,2),
`student_id` INT,
CONSTRAINT `fk_payments_students`
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`)
);

CREATE TABLE `agenda`(
`student_id` INT,
`subject_id` INT,
PRIMARY KEY (`student_id`,`subject_id`),
CONSTRAINT `fk_agenda_students`
FOREIGN KEY (`student_id`)
REFERENCES `students`(`student_id`),
CONSTRAINT `fk_agenda_subjects`
FOREIGN KEY (`subject_id`)
REFERENCES `subjects`(`subject_id`)
);

-- 9.	Peaks in Rila
SELECT m.`mountain_range`, p.`peak_name`, p.`elevation`
FROM `mountains` AS m
JOIN `peaks` AS p
ON p.`mountain_id` =  m.`id`
WHERE m.`mountain_range` = 'Rila'
ORDER BY p.`elevation` DESC;
		
