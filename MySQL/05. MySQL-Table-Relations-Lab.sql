-- Lab
-- 1.	 Mountains and Peaks
CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`mountain_id` INT NOT NULL,
CONSTRAINT `fk_peaks_mountains`
FOREIGN KEY (`mountain_id`)
REFERENCES `mountains` (`id`)
);

-- 2.	 Trip Organization
SELECT v.driver_id, v.vehicle_type,
CONCAT(first_name, ' ', last_name) AS driver_name
FROM campers AS c
JOIN vehicles  AS v
ON v.driver_id = c.id;

-- 3.	SoftUni Hiking
SELECT r.starting_point AS route_starting_point, r.end_point AS route_ending_point, r.leader_id,
CONCAT(first_name, ' ', last_name) AS leader_name
FROM campers AS c
JOIN routes  AS r
ON r.leader_id = c.id;

-- 4. Delete Mountains
 DROP TABLE `peaks`;
 DROP TABLE `mountains`;
 
 CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`mountain_id` INT NOT NULL,
CONSTRAINT `fk_peaks_mountains`
FOREIGN KEY (`mountain_id`)
REFERENCES `mountains` (`id`)
ON DELETE CASCADE
);

-- 5.	 Project Management DB*
CREATE TABLE `clients`(
`id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`client_name` VARCHAR (100)
);

CREATE TABLE `projects`(
`id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`client_id` INT,
`project_lead_id` INT
);

CREATE TABLE `employees`(
`id` INT(11) PRIMARY KEY AUTO_INCREMENT,
`first_name` VARCHAR (30),
`last_name` VARCHAR (30),
`project_id` INT,
CONSTRAINT `fk_employees_projects`
FOREIGN KEY (`project_id`)
REFERENCES `projects`(`id`)
);

ALTER TABLE `projects`
ADD CONSTRAINT `fk_projects_employees`
FOREIGN KEY (`project_lead_id`)
REFERENCES `employees`(`id`);

ALTER TABLE `projects`
ADD CONSTRAINT`fk_projects_clients`
FOREIGN KEY (`client_id`)
REFERENCES `clients`(`id`);