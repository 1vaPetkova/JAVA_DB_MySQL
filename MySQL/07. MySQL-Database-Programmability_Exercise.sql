-- 1.	Employees with Salary Above 35000

DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000 ()
BEGIN
SELECT first_name, last_name
FROM employees
WHERE salary > 35000
ORDER BY first_name, last_name, employee_id;
END $$

DELIMITER ;

CALL usp_get_employees_salary_above_35000();

-- 02. Employees with Salary Above Number
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above (sal DECIMAL(19,4))
BEGIN
SELECT first_name, last_name
FROM employees
WHERE salary >= sal
ORDER BY first_name, last_name, employee_id;
END $$

DELIMITER ;

CALL usp_get_employees_salary_above(45000);

-- 3.	Town Names Starting With
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with (town_name VARCHAR(10))
BEGIN
SELECT `name` AS town_name
FROM towns
WHERE LEFT(`name`, char_length(town_name)) = town_name
ORDER BY `name`;
END $$

DELIMITER ;

CALL usp_get_towns_starting_with('b');

-- 4.	Employees from Town
DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town (town_name VARCHAR(10))
BEGIN
SELECT first_name, last_name
FROM employees AS e
JOIN addresses AS a
USING (address_id)
JOIN towns AS t
USING (town_id)
WHERE t.`name` = town_name
ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;
CALL usp_get_employees_from_town('Sofia');

-- 5.	Salary Level Function
DELIMITER $$
CREATE FUNCTION ufn_get_salary_level (sal DECIMAL(19,2))
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
    RETURN (CASE
    WHEN sal < 30000 THEN'Low'
    WHEN sal <= 50000 THEN 'Average'
    ELSE 'High'
END
);
 END $$
 
 DELIMITER ;

SELECT (ufn_get_salary_level(13500.00));    
SELECT (ufn_get_salary_level(43300.00));    
SELECT (ufn_get_salary_level(125500.00));    

-- 6.	Employees by Salary Level
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level (salary_level VARCHAR(10))
BEGIN
SELECT first_name, last_name
FROM employees AS e
WHERE ufn_get_salary_level(salary) = salary_level
ORDER BY e.first_name DESC, e.last_name DESC ;
END $$

-- Option 2
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level (salary_level VARCHAR(10))
BEGIN
SELECT first_name, last_name
FROM employees AS e
WHERE 
CASE
	WHEN salary_level = 'High' THEN salary > 50000
	WHEN salary_level = 'Average' THEN salary BETWEEN 30000 AND 50000
	WHEN salary_level = 'Low' THEN salary < 30000
    END
ORDER BY e.first_name DESC, e.last_name DESC ;
END $$

DELIMITER ;

CALL usp_get_employees_by_salary_level('High');

-- 7.	Define Function
DELIMITER $$
CREATE FUNCTION ufn_is_word_comprised(set_of_letters VARCHAR(50), word VARCHAR(50))
RETURNS INT DETERMINISTIC
BEGIN
 RETURN word REGEXP (concat('^[', set_of_letters, ']+$'));
 END $$
 
DELIMITER ;
SELECT ufn_is_word_comprised('oistmiahf', 'Sofia');
SELECT ufn_is_word_comprised('oistmiahf', 'halves');
SELECT ufn_is_word_comprised('bobr', 'Rob');
SELECT ufn_is_word_comprised('pppp', 'Guy');

-- 8.	Find Full Name
DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name ()
BEGIN
SELECT CONCAT_WS(' ',first_name, last_name) AS full_name
FROM account_holders AS ah
ORDER BY full_name, id;
END $$

DELIMITER ;
CALL usp_get_holders_full_name();

-- 9.	People with Balance Higher Than
DELIMITER $$
CREATE FUNCTION get_sum_balance (holder_id INT)
RETURNS INT DETERMINISTIC
BEGIN
RETURN (
 SELECT SUM(balance)
 FROM accounts AS a
 WHERE a.account_holder_id = holder_id
 );
 END $$
 
CREATE PROCEDURE usp_get_holders_with_balance_higher_than (balance DECIMAL(19,2))
BEGIN
SELECT first_name, last_name
FROM account_holders AS ah
JOIN accounts AS a
ON ah.id = a.account_holder_id
WHERE get_sum_balance(a.account_holder_id) > balance
GROUP BY a.account_holder_id
ORDER BY a.account_holder_id ;
END $$

-- Option 2
CREATE PROCEDURE usp_get_holders_with_balance_higher_than (balance DECIMAL(19,2))
BEGIN
SELECT first_name, last_name
FROM account_holders AS ah
JOIN accounts AS a
ON ah.id = a.account_holder_id
GROUP BY ah.id
HAVING SUM(a.balance) > balance
ORDER BY ah.id ;
END $$

DELIMITER ;
CALL usp_get_holders_with_balance_higher_than (7000);

-- 10.	Future Value Function
DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(sum DECIMAL(19,4), yearly_interest_rate DOUBLE, number_of_years INT)
RETURNS DECIMAL (19,4) DETERMINISTIC
BEGIN
RETURN sum * POW((1+yearly_interest_rate),number_of_years);
END $$

SELECT ufn_calculate_future_value(1000,0.5,5);

-- 11.	Calculating Interest
DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(balance DECIMAL(19,4), interest DECIMAL(19,4), years INT)
RETURNS DECIMAL (19,4) DETERMINISTIC
BEGIN
RETURN balance * POW((1+interest),years);
END $$

CREATE PROCEDURE usp_calculate_future_value_for_account (acc_id INT, interest DECIMAL(19,4))
BEGIN

SELECT a.id AS account_id, ah.first_name, ah.last_name, a.balance AS current_balance, 
(SELECT ufn_calculate_future_value(a.balance,interest,5)) AS balance_in_5_years
FROM account_holders AS ah
JOIN accounts AS a
ON a.account_holder_id = ah.id
WHERE a.id = acc_id;
END $$

DELIMITER ;

CALL usp_calculate_future_value_for_account(1, 0.1);

-- 12.	Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4)) 
BEGIN
START TRANSACTION; 
IF(money_amount <=0 ) THEN ROLLBACK;
ELSE
UPDATE accounts AS a
SET a.balance = a.balance + money_amount
WHERE a.id = account_id;
COMMIT;
END IF;
END $$

DELIMITER ;
CALL usp_deposit_money(1,10);

-- 13.	Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4)) 
BEGIN
START TRANSACTION; 
IF ((SELECT COUNT(*) FROM accounts  WHERE id = account_id) = 0)
OR (money_amount < 0) 
OR ((SELECT balance FROM accounts  WHERE id = account_id) < money_amount)
THEN ROLLBACK;
ELSE
UPDATE accounts AS a
SET a.balance = a.balance - money_amount
WHERE a.id = account_id;
COMMIT;
END IF;
END $$

DELIMITER ;
CALL usp_withdraw_money(1,10);

-- 14.	Money Transfer
DELIMITER $$
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19,4)) 
BEGIN
START TRANSACTION; 
IF ((SELECT COUNT(*) FROM accounts  WHERE id = from_account_id) = 0)
OR ((SELECT COUNT(*) FROM accounts  WHERE id = to_account_id) = 0)
OR (amount < 0) 
OR ((SELECT balance FROM accounts  WHERE id = from_account_id) < amount)
THEN ROLLBACK;
ELSE
UPDATE accounts AS a
SET a.balance = a.balance - amount
WHERE a.id = from_account_id;
UPDATE accounts AS a
SET a.balance = a.balance + amount
WHERE a.id = to_account_id;
COMMIT;
END IF;
END $$

DELIMITER ;
CALL usp_transfer_money(1,2,10);

-- 15.	Log Accounts Trigger
CREATE TABLE `logs` (
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(19,4) NOT NULL,
new_sum DECIMAL (19,4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_update_accounts
AFTER UPDATE 
ON accounts 
FOR EACH ROW 
BEGIN
INSERT INTO `logs` (account_id, old_sum, new_sum)
VALUES (OLD.id, OLD.balance, NEW.balance);
END $$

DELIMITER ;

DROP TRIGGER tr_update_accounts;

UPDATE accounts
SET balance = balance - 10
WHERE id = 1;

SELECT log_id, account_id, old_sum, new_sum
FROM `logs`;

-- 16.	Emails Trigger
CREATE TABLE `logs`(
log_id INT PRIMARY KEY AUTO_INCREMENT,
account_id INT NOT NULL,
old_sum DECIMAL(20,4) NOT NULL,
new_sum DECIMAL(20,4) NOT NULL);

DELIMITER $$
CREATE TRIGGER log_balance_changes 
AFTER UPDATE 
ON accounts 
FOR EACH ROW
BEGIN
	CASE WHEN OLD.balance != NEW.balance THEN 
		 INSERT INTO `logs`(account_id, old_sum, new_sum)
		 VALUES (OLD.id, OLD.balance, NEW.balance);
	ELSE
		BEGIN END;
	END CASE;
END $$

DELIMITER ;

CREATE TABLE notification_emails(
id INT PRIMARY KEY AUTO_INCREMENT,
recipient INT NOT NULL,
subject VARCHAR(50) NOT NULL,
body TEXT NOT NULL);

DELIMITER $$
CREATE TRIGGER create_notification_email 
AFTER 
INSERT 
ON `logs` 
FOR EACH ROW
BEGIN 
	INSERT INTO notification_emails (recipient, subject, body)
	VALUES (NEW.account_id, CONCAT('Balance change for account: ', NEW.account_id),
	CONCAT('On ', DATE_FORMAT(NOW(), '%b %d %Y'), ' at ', DATE_FORMAT(NOW(), '%r'),
	' your account balance was changed from ', NEW.old_sum, ' to ', NEW.new_sum, '.'));
END $$
DELIMITER ;

