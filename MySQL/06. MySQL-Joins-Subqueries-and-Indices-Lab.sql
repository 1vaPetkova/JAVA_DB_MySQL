-- Lab
-- 1.	Managers
SELECT e.`employee_id`,, CONCAT(e.`first_name`, ' ', e.`last_name`) AS full_name, d.`department_id`, d.`name` AS department_name
FROM employees as e
JOIN departments AS d
ON e.employee_id = d.manager_id
ORDER BY employee_id
LIMIT 5;

-- 2.	Towns Addresses
SELECT t.`town_id`, t.`name`, a.`address_text`
FROM `towns` AS t
LEFT JOIN `addresses` AS a
USING (`town_id`)
WHERE t.`town_id` IN (9,15,32)
ORDER BY t.`town_id`, a.`address_id`;

-- 3.	Employees Without Managers
SELECT `employee_id`, `first_name`, `last_name`, `department_id`, `salary`
FROM `employees`
WHERE `manager_id` IS NULL;

-- 4.	Higher Salary
SELECT COUNT(*) AS 'count'
FROM `employees`
WHERE `salary` > (
SELECT AVG(`salary`)
FROM `employees`
);








