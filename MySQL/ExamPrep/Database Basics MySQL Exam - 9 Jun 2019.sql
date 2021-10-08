CREATE SCHEMA ruk_database;
USE ruk_database;

-- 01.	Table Design

CREATE TABLE branches(
id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(30) NOT NULL 
);

CREATE TABLE employees (
id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL (10,2) NOT NULL,
started_on DATE NOT NULL,
branch_id INT NOT NULL,
CONSTRAINT fk_employees_branches
FOREIGN KEY (branch_id)
REFERENCES branches(id)
);

CREATE TABLE clients(
id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
age INT NOT NULL
);

CREATE TABLE employees_clients(
employee_id INT,
client_id INT,
CONSTRAINT fk_ec_employees
FOREIGN KEY (employee_id)
REFERENCES employees(id),
CONSTRAINT fk_ec_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);

CREATE TABLE bank_accounts(
id INT PRIMARY KEY AUTO_INCREMENT,
account_number VARCHAR(10) NOT NULL, 
balance DECIMAL (10,2) NOT NULL,
client_id INT NOT NULL UNIQUE,
CONSTRAINT fk_ba_clients
FOREIGN KEY (client_id)
REFERENCES clients(id)
);


CREATE TABLE cards(
id INT PRIMARY KEY AUTO_INCREMENT,
card_number VARCHAR(19) NOT NULL,
card_status VARCHAR(7) NOT NULL,
bank_account_id INT NOT NULL,
CONSTRAINT fk_cards_bank_accounts
FOREIGN KEY (bank_account_id)
REFERENCES bank_accounts(id)
);


-- 02.	Insert
INSERT INTO cards (card_number, card_status, bank_account_id)
SELECT REVERSE(c.full_name), 'Active', c.id
FROM clients AS c
WHERE c.id BETWEEN 191 and 200;

-- 03.	Update
UPDATE employees_clients 
SET employee_id = (
SELECT ec.employee_id 
FROM (SELECT * FROM employees_clients) AS ec -- we clone the table!
GROUP BY ec.employee_id
ORDER BY COUNT(ec.client_id), ec.employee_id
LIMIT 1
)
WHERE employee_id = client_id;

-- 04.	Delete
DELETE FROM employees
WHERE id NOT IN (SELECT employee_id FROM employees_clients);

-- 05.	Clients
SELECT id, full_name FROM clients ORDER BY id;

-- 06.	Newbies
SELECT id, concat(first_name,' ', last_name) AS full_name, concat('$','',salary), started_on
FROM employees
WHERE salary >= 100000 AND started_on >= '2018-01-01'
ORDER BY salary DESC, id;

-- 07.	Cards against Humanity
SELECT c.id, concat_WS(' : ',c.card_number, cl.full_name) AS card_token
FROM cards AS c
JOIN bank_accounts AS ba ON c.bank_account_id = ba.id
JOIN clients AS cl ON cl.id = ba.client_id
ORDER BY c.id DESC;

-- 08.	Top 5 Employees
SELECT concat_ws(' ', e.first_name, e.last_name), e.started_on, COUNT(ec.client_id) AS count_of_clients
FROM employees AS e
JOIN employees_clients AS ec ON e.id = ec.employee_id
GROUP BY ec.employee_id
ORDER BY count_of_clients DESC, e.id
LIMIT 5;

-- 09.	Branch cards
SELECT b.name, 
COUNT(c.id) AS count_of_cards
FROM branches AS b
LEFT JOIN employees AS e ON e.branch_id = b.id
LEFT JOIN employees_clients AS ec ON ec.employee_id = e.id
LEFT JOIN clients AS cl ON cl.id = ec.client_id
LEFT JOIN bank_accounts AS ba ON ba.client_id = cl.id
LEFT JOIN cards AS c ON c.bank_account_id = ba.id
GROUP BY b.id
ORDER BY count_of_cards DESC, b.name;

-- Option 2
SELECT b.name, (
COUNT(
CASE 
WHEN e.id NOT IN (SELECT employee_id FROM employees_clients)  
AND
cl.id NOT IN (SELECT client_id FROM employees_clients) THEN 0
ELSE c.id
END
)) AS count_of_cards
FROM branches AS b
LEFT JOIN employees AS e ON e.branch_id = b.id
LEFT JOIN employees_clients AS ec ON ec.employee_id = e.id
LEFT JOIN clients AS cl ON cl.id = ec.client_id
LEFT JOIN bank_accounts AS ba ON ba.client_id = cl.id
LEFT JOIN cards AS c ON c.bank_account_id = ba.id
GROUP BY b.id
ORDER BY count_of_cards DESC, b.name;

-- 10.	Extract client cards count
DELIMITER $$
CREATE FUNCTION udf_client_cards_count(name VARCHAR(30)) 
RETURNS INT DETERMINISTIC
BEGIN
RETURN (
SELECT COUNT(c.id)
FROM cards AS c 
JOIN bank_accounts AS ba ON c.bank_account_id = ba.id
JOIN clients AS cl ON cl.id = ba.client_id
WHERE cl.full_name = name);
END $$

DELIMITER ;

SELECT c.full_name, udf_client_cards_count('Baxy David') as `cards` FROM clients c
WHERE c.full_name = 'Baxy David';

-- 11.	Extract Client Info
DELIMITER $$
CREATE PROCEDURE udp_clientinfo(full_name VARCHAR(50))
DETERMINISTIC
BEGIN
SELECT cl.full_name, cl.age, ba.account_number, concat('$','',ba.balance) AS balance
FROM clients AS cl
JOIN bank_accounts AS ba ON ba.client_id = cl.id
WHERE cl.full_name = full_name;
END $$
DELIMITER ;

CALL udp_clientinfo('Hunter Wesgate');