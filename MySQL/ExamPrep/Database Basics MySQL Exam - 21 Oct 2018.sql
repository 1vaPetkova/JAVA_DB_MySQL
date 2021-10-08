CREATE SCHEMA colonial_journey_management_system_db;
USE colonial_journey_management_system_db;

-- 00.	Table Design
CREATE TABLE planets(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL
);

CREATE TABLE spaceports(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
planet_id INT,
CONSTRAINT fk_spaceports_planets
FOREIGN KEY (planet_id)
REFERENCES planets(id)
);

CREATE TABLE colonists(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
ucn CHAR(10) NOT NULL,
birth_date DATE NOT NULL
);

CREATE TABLE spaceships(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
manufacturer VARCHAR(30) NOT NULL,
light_speed_rate INT
);

CREATE TABLE journeys(
id INT PRIMARY KEY AUTO_INCREMENT,
journey_start DATETIME NOT NULL,
journey_end DATETIME NOT NULL,
purpose ENUM('Medical', 'Technical', 'Educational', 'Military') NOT NULL,
destination_spaceport_id INT,
spaceship_id INT,
CONSTRAINT fk_journeys_destination_spaceport
FOREIGN KEY (destination_spaceport_id)
REFERENCES spaceports(id),
CONSTRAINT fk_journeys_spaceship
FOREIGN KEY (spaceship_id)
REFERENCES spaceships(id)
);

CREATE TABLE travel_cards(
id INT PRIMARY KEY AUTO_INCREMENT,
card_number CHAR(10) NOT NULL,
job_during_journey ENUM('Pilot','Engineer','Trooper','Cleaner','Cook') NOT NULL,
colonist_id INT,
journey_id INT,
CONSTRAINT fk_journeys_colonists
FOREIGN KEY (colonist_id)
REFERENCES colonists(id),
CONSTRAINT fk_journeys_journeys
FOREIGN KEY (journey_id)
REFERENCES journeys(id)
);

-- 01.	Data Insertion
INSERT INTO travel_cards (card_number, job_during_journey, colonist_id, journey_id)
SELECT(
CASE
	WHEN birth_date >'1980-01-01' THEN CONCAT_WS('',YEAR(c.birth_date), DAY(c.birth_date), LEFT(c.ucn,4))
    ELSE CONCAT_WS('',YEAR(c.birth_date), MONTH(c.birth_date), RIGHT(c.ucn,4))
END) AS card_number,
(
CASE
	WHEN c.id % 2 = 0 THEN 'Pilot'
	WHEN c.id % 3 = 0 THEN 'Cook'
	ELSE 'Engineer'
END)  AS job_during_journey,
c.id as colonist_id,
LEFT(c.ucn,1) AS journey_id
FROM colonists AS c
WHERE c.id BETWEEN 96 AND 100;

-- 02.	Data Update
UPDATE journeys
SET purpose =
(
CASE 
	WHEN id % 2 = 0 THEN 'Medical'
	WHEN id % 3 = 0 THEN 'Technical'
	WHEN id % 5 = 0 THEN 'Educational'
	WHEN id % 7 = 0 THEN 'Military'
    ELSE purpose
END
);

-- 03.	Data Deletion
DELETE FROM colonists AS c
WHERE c.id NOT IN (SELECT colonist_id FROM travel_cards);

-- 04.Extract all travel cards
SELECT card_number, job_during_journey
FROM travel_cards
ORDER BY card_number;

-- 05. Extract all colonists
SELECT id, CONCAT_WS(' ',first_name, last_name), ucn
FROM colonists
ORDER BY first_name, last_name, id;

-- 06.	Extract all military journeys
SELECT id, journey_start, journey_end
FROM journeys
WHERE purpose = 'Military'
ORDER BY journey_start;

-- 07.	Extract all pilots
SELECT c.id, CONCAT_WS(' ', c.first_name, c.last_name) AS full_name
FROM colonists AS c
JOIN travel_cards AS t
ON t.colonist_id = c.id
WHERE t.job_during_journey = 'Pilot'
ORDER BY c.id ;

-- 08.	Count all colonists that are on technical journey
SELECT COUNT(*) AS count
FROM colonists AS c
JOIN travel_cards AS t
ON t.colonist_id = c.id
JOIN journeys AS j
ON t.journey_id = j.id
WHERE j.purpose = 'Technical';

-- 09.Extract the fastest spaceship
SELECT sh.name AS spaceship_name, sp.name AS spaceport_name
FROM spaceships AS sh
JOIN journeys AS j
ON j.spaceship_id = sh.id
JOIN spaceports AS sp
ON j.destination_spaceport_id = sp.id
ORDER BY sh.light_speed_rate DESC
LIMIT 1;

-- 10.Extract spaceships with pilots younger than 30 years
SELECT s.name, s.manufacturer
FROM spaceships AS s
RIGHT JOIN journeys AS j ON s.id = j.spaceship_id
RIGHT JOIN travel_cards AS t ON t.journey_id = j.id
RIGHT JOIN colonists AS c ON t.colonist_id = c.id
WHERE YEAR('2019-01-01')- YEAR(c.birth_date) < 30
AND t.job_during_journey = 'Pilot'
ORDER BY s.name;

-- 11. Extract all educational mission planets and spaceports
SELECT p.name AS planet_name, s.name AS spaceport_name 
FROM planets AS p 
JOIN spaceports AS s ON p.id = s.planet_id
JOIN journeys AS j ON j.destination_spaceport_id = s.id
WHERE j.purpose = 'Educational'
ORDER BY s.name DESC;

-- 12. Extract all planets and their journey count
SELECT p.name AS planet_name, COUNT(*) AS journeys_count
FROM planets AS p 
JOIN spaceports AS s ON p.id = s.planet_id
JOIN journeys AS j ON j.destination_spaceport_id = s.id
GROUP BY p.name
ORDER BY journeys_count DESC, p.name;

-- 13.Extract the shortest journey
SELECT j.id, p.name AS planet_name, s.name AS spaceport_name, j.purpose AS journey_purpose
FROM journeys AS j
LEFT JOIN spaceports AS s ON j.destination_spaceport_id = s.id 
LEFT JOIN planets AS p ON p.id = s.planet_id
ORDER BY DATEDIFF(j.journey_end, j.journey_start) 
LIMIT 1;

-- 14.Extract the less popular job
SELECT t.job_during_journey AS job_name
FROM travel_cards AS t
JOIN journeys AS j ON t.journey_id = j.id
ORDER BY DATEDIFF(j.journey_end, j.journey_start) DESC,
(
SELECT COUNT(*) AS cn 
FROM travel_cards 
GROUP BY job_during_journey 
ORDER BY cn
LIMIT 1
)
LIMIT 1;

-- Option 2
SELECT t.job_during_journey AS job_name
FROM travel_cards AS t
WHERE t.journey_id = 
( 
SELECT j.id 
FROM journeys AS j
ORDER BY DATEDIFF(j.journey_end, j.journey_start) DESC LIMIT 1
)
GROUP BY job_name
ORDER BY COUNT(job_name) LIMIT 1;

-- 15. Get colonists count

DELIMITER $$
CREATE FUNCTION udf_count_colonists_by_destination_planet (planet_name VARCHAR (30)) 
RETURNS INT DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(*)
FROM colonists AS c
JOIN travel_cards AS t ON t.colonist_id = c.id
JOIN journeys AS j ON t.journey_id = j.id
JOIN spaceports AS s ON s.id = j.destination_spaceport_id
JOIN planets AS p ON s.planet_id = p.id
WHERE p.name = planet_name);
END $$

DELIMITER ;
SELECT udf_count_colonists_by_destination_planet('Otroyphus') AS count;

-- 16. Modify spaceship
DELIMITER $$
CREATE PROCEDURE udp_modify_spaceship_light_speed_rate(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
DETERMINISTIC
BEGIN 
START TRANSACTION;
IF spaceship_name  NOT IN (SELECT `name` FROM spaceships) THEN 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
    ROLLBACK;
ELSE 
UPDATE spaceships
SET light_speed_rate = light_speed_rate + light_speed_rate_increse
WHERE `name` = spaceship_name;
END IF;
COMMIT;
END $$

DELIMITER ;
CALL udp_modify_spaceship_light_speed_rate('Na Pesho koraba',1914);
CALL udp_modify_spaceship_light_speed_rate('USS Templar',5);

SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';

