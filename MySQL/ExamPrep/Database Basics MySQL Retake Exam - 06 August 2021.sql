CREATE SCHEMA sgd;
USE sgd ;

CREATE TABLE addresses(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL
);

CREATE TABLE offices(
id INT PRIMARY KEY AUTO_INCREMENT,
workspace_capacity INT NOT NULL,
website VARCHAR(50),
address_id INT NOT NULL,
CONSTRAINT fk_offices_addresses
FOREIGN KEY (address_id)
REFERENCES addresses(id)
);

CREATE TABLE employees(
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
salary DECIMAL (10,2) NOT NULL,
job_title VARCHAR(20) NOT NULL,
happiness_level CHAR(1) NOT NULL
);

CREATE TABLE teams(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(40) NOT NULL,
office_id INT NOT NULL,
leader_id INT NOT NULL UNIQUE,
CONSTRAINT fk_teams_offices
FOREIGN KEY (office_id)
REFERENCES offices(id),
CONSTRAINT fk_teams_employees
FOREIGN KEY (leader_id)
REFERENCES employees(id)
);

CREATE TABLE games(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(50) NOT NULL,
`description` TEXT,
rating FLOAT NOT NULL,
budget DECIMAL (10,2) NOT NULL,
release_date DATE,
team_id INT NOT NULL,
CONSTRAINT fk_games_teams
FOREIGN KEY (team_id)
REFERENCES teams(id)
);

CREATE TABLE categories (
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(10) NOT NULL
);

CREATE TABLE games_categories(
game_id INT NOT NULL,
category_id INT NOT NULL,
PRIMARY KEY (game_id, category_id),
CONSTRAINT fk_gc_games
FOREIGN KEY (game_id)
REFERENCES games(id),
CONSTRAINT fk_gc_categories
FOREIGN KEY (category_id)
REFERENCES categories(id)
);

-- 2.	Insert
INSERT INTO games (name, rating, budget, team_id)
SELECT LOWER(REVERSE(SUBSTRING(t.name,2,char_length(t.name)))),  t.id, t.leader_id * 1000, t.id FROM teams AS t
WHERE t.id BETWEEN 1 AND 9;

-- 3.	Update
UPDATE employees AS e
SET e.salary = salary + 1000
WHERE e.id IN (SELECT leader_id FROM teams) AND e.age < 40 AND e.salary < 5000;

-- 4.	Delete
DELETE FROM games as g
WHERE g.id NOT IN (SELECT game_id FROM games_categories) AND release_date IS NULL;

-- 5.	Employees
SELECT first_name, last_name, age, salary, happiness_level FROM employees ORDER BY salary, id;

-- 6.	    Addresses of the teams
SELECT t.name, a.name, CHAR_LENGTH(a.name)
FROM teams AS t
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON a.id = o.address_id
WHERE o.website IS NOT NULL
ORDER BY t.name, a.name;

-- 7.	    Categories Info
SELECT c.name, COUNT(gc.game_id) AS games_count, ROUND(AVG(g.budget),2) AS avg_budget, MAX(g.rating) AS max_rating
FROM categories AS c
LEFT JOIN games_categories AS gc ON c.id = gc.category_id
LEFT JOIN games AS g ON g.id = gc.game_id
GROUP BY c.id
HAVING max_rating >= 9.5
ORDER BY games_count DESC, c.name;

-- 8.	Games of 2022
SELECT g.name, g.release_date, CONCAT(LEFT(g.description, 10),'','...') AS summary, 
CASE
	WHEN MONTH(release_date) <= 3 THEN 'Q1'
	WHEN MONTH(release_date) <= 6 THEN 'Q2'
	WHEN MONTH(release_date) <= 9 THEN 'Q3'
	ELSE 'Q4'
END
AS `quarter`,
t.name
FROM games AS g
JOIN teams AS t ON t.id = g.team_id
WHERE YEAR(g.release_date) = '2022'AND MONTH(g.release_date) % 2 = 0 AND g.name LIKE '%2'
ORDER BY `quarter`;

-- 9.	Full info for games
SELECT g.name, IF(g.budget < 50000, 'Normal budget', 'Insufficient budget') AS budget_level, t.name AS team_name, a.name AS address_name
FROM games AS g
JOIN teams AS t ON g.team_id = t.id
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON o.address_id = a.id
WHERE g.id NOT IN (SELECT game_id FROM games_categories) AND g.release_date IS NULL
ORDER BY g.name;

-- 10.	Find all basic information for a game
DELIMITER $$
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20)) 
RETURNS TEXT DETERMINISTIC
BEGIN
RETURN (
SELECT CONCAT_WS(' ','The',g.name,'is developed by a',t.name,'in an office with an address',a.name)
FROM games AS g
JOIN teams AS t ON g.team_id = t.id
JOIN offices AS o ON o.id = t.office_id
JOIN addresses AS a ON a.id = o.address_id
WHERE g.name = game_name);
END $$
DELIMITER ;

SELECT udf_game_info_by_name('Bitwolf') AS info;
SELECT udf_game_info_by_name('Fix San') AS info;
SELECT udf_game_info_by_name('Job') AS info;

-- 11.	Update budget of the games 
DELIMITER $$
CREATE PROCEDURE udp_update_budget (min_game_rating FLOAT)
DETERMINISTIC
BEGIN
UPDATE games AS g
SET g.budget = g.budget + 100000, g.release_date = DATE_ADD(g.release_date, INTERVAL 1 YEAR)
WHERE g.id NOT IN (SELECT game_id FROM games_categories) 
AND g.release_date IS NOT NULL
AND g.rating > min_game_rating;
END $$
DELIMITER ;

CALL udp_update_budget (8);


SELECT * FROM games
WHERE rating > 8 AND release_date IS NOT NULL
AND id NOT IN (SELECT game_id FROM games_categories);

SELECT SUM(`budget`) FROM  `games`;




