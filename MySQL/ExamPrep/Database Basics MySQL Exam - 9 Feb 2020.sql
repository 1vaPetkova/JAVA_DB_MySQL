-- Section 0: Database Overview
CREATE SCHEMA fsd;
USE fsd;
CREATE TABLE skills_data(
id INT PRIMARY KEY AUTO_INCREMENT,
dribbling INT,
pace INT,
passing INT,
shooting INT,
speed INT,
strength INT
);

CREATE TABLE countries (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(45) NOT NULL
);

CREATE TABLE towns (
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
country_id INT,
CONSTRAINT fk_towns_countries
FOREIGN KEY (country_id)
REFERENCES countries(id)
);

CREATE TABLE stadiums(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id INT,
CONSTRAINT fk_stadiums_towns
FOREIGN KEY (town_id)
REFERENCES towns(id)
);

CREATE TABLE teams(
id INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT(20) NOT NULL,
stadium_id INT NOT NULL,
CONSTRAINT fk_teams_stadiums
FOREIGN KEY (stadium_id)
REFERENCES stadiums(id)
);

CREATE TABLE coaches (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL
);

CREATE TABLE players(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT 0,
position CHAR NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
hire_date DATETIME,
skills_data_id INT NOT NULL,
team_id INT,
CONSTRAINT fk_players_teams
FOREIGN KEY (team_id)
REFERENCES teams(id),
CONSTRAINT fk_players_skills_data
FOREIGN KEY (skills_data_id)
REFERENCES skills_data(id)
);

CREATE TABLE players_coaches (
player_id INT,
coach_id INT,
PRIMARY KEY (player_id, coach_id),
CONSTRAINT fk_pc_coaches
FOREIGN KEY (coach_id)
REFERENCES coaches(id),
CONSTRAINT fk_pc_players
FOREIGN KEY (player_id)
REFERENCES players(id)
);

-- 2.	Insert
INSERT INTO coaches (first_name, last_name, salary, coach_level)
SELECT p.first_name, p.last_name, p.salary*2, char_length(p.first_name)
FROM players AS p
WHERE p.age >= 45;

-- 3.	Update
UPDATE coaches AS c
SET c.coach_level = c.coach_level + 1
WHERE (
SELECT COUNT(*)  AS count
FROM players_coaches AS pc
WHERE pc.coach_id = c.id
GROUP BY pc.coach_id 
HAVING count >= 1) 
AND c.first_name LIKE 'A%';

-- 4.	Delete
DELETE FROM players
WHERE age >= 45;

-- 5.  Players
SELECT first_name, age, salary
FROM players
ORDER BY salary DESC;

-- 6.	Young offense players without contract
SELECT p.id, CONCAT_WS(' ', p.first_name, p.last_name), p.age, p.position, p.hire_date
FROM players AS p
JOIN skills_data AS sd
ON p.skills_data_id = sd.id
WHERE p.age < 23 
AND position = 'A'
AND sd.strength > 50
AND hire_date IS NULL
ORDER BY p.salary, p.age;

-- 7.	Detail info for all teams
SELECT t.`name`, t.established, t.fan_base, COUNT(p.id) AS players_count
FROM teams AS t
LEFT JOIN players AS p
ON p.team_id = t.id
GROUP BY t.id
ORDER BY players_count DESC, fan_base DESC;

-- Option 2
SELECT t.`name`, t.established, t.fan_base, (SELECT COUNT(*) FROM players WHERE t.id = team_id) AS players_count
FROM teams AS t
ORDER BY players_count DESC, fan_base DESC;
 
-- 8.	The fastest player by towns
SELECT MAX(sd.speed) AS max_speed, tw.name AS town_name
FROM skills_data AS sd
RIGHT JOIN players AS p
ON p.skills_data_id = sd.id
RIGHT JOIN teams AS t
ON p.team_id = t.id
RIGHT JOIN stadiums AS s
ON t.stadium_id = s.id
RIGHT JOIN towns as tw
ON s.town_id = tw.id
WHERE t.name NOT IN ('Devify')
GROUP BY tw.name
ORDER BY max_speed DESC, tw.name;

-- 9.	Total salaries and players by country
SELECT c.name,  COUNT(p.id) AS total_count_of_players, SUM(p.salary) AS total_sum_of_salaries
FROM countries AS c
LEFT JOIN towns as tw
ON c.id = country_id
LEFT JOIN stadiums AS st
ON st.town_id = tw.id
LEFT JOIN teams AS t
ON t.stadium_id = st.id
LEFT JOIN players AS p
ON p.team_id = t.id
GROUP BY c.id
ORDER BY total_count_of_players DESC, c.name;

-- 10.	Find all players that play on stadium
DELIMITER $$
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
RETURNS INT DETERMINISTIC
 BEGIN
RETURN ( SELECT COUNT(*)
FROM players AS p
JOIN teams AS t
ON p.team_id = t.id
JOIN stadiums AS s
ON t.stadium_id = s.id
WHERE s.name = stadium_name);
END $$

DELIMITER ;
SELECT udf_stadium_players_count('Jaxworks') AS 'count';
SELECT udf_stadium_players_count('Linklinks') AS 'count';

-- 11.	Find good playmaker by teams
DELIMITER $$
CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name VARCHAR (45))
BEGIN
SELECT CONCAT_WS(' ', p.first_name, p.last_name) AS full_name, p.age, p.salary, sd.dribbling, sd.speed, team_name
FROM players AS p 
JOIN teams as t 
ON t.id = p.team_id
JOIN skills_data AS sd
ON sd.id = p.skills_data_id
WHERE sd.dribbling > min_dribble_points
AND t.`name` = team_name
AND sd.speed > (
SELECT AVG (speed) 
FROM skills_data
)
ORDER BY sd.speed DESC
LIMIT 1;
END $$

DELIMITER ;

CALL udp_find_playmaker (20, 'Skyble');

