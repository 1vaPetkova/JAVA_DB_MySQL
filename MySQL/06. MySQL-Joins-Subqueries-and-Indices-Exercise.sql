-- Exercise
-- 1.	Employee Address
SELECT e.employee_id, e.job_title, e.address_id, a.address_text
FROM employees AS e
LEFT JOIN addresses AS a
USING (address_id)
ORDER BY address_id
LIMIT 5;

-- 2.	Addresses with Towns
SELECT e.first_name,e.last_name, t.name, a.address_text
FROM employees AS e
JOIN addresses AS a
USING (address_id)
JOIN towns AS t
USING (town_id)
ORDER BY first_name, last_name
LIMIT 5;

-- 3.	Sales Employee
SELECT e.employee_id, e.first_name, e.last_name, d.name
FROM employees AS e
LEFT JOIN departments AS d
USING (department_id)
WHERE d.name = 'Sales'
ORDER BY e.employee_id DESC;

-- 4.	Employee Departments
SELECT e.employee_id, e.first_name, e.salary, d.`name` AS 'department_name'
FROM employees AS e
JOIN departments AS d
ON e.department_id = d.department_id
WHERE e.salary > 15000 
ORDER BY e.department_id DESC
LIMIT 5;

-- 5.	Employees Without Project
SELECT e.employee_id, e.first_name
FROM employees AS e
WHERE e.employee_id NOT IN (
SELECT ep.employee_id 
FROM employees_projects AS ep
)
ORDER BY e.employee_id DESC
LIMIT 3;

-- 5.	Employees Without Project JOIN 
SELECT e.employee_id, e.first_name
FROM employees AS e
LEFT JOIN employees_projects AS ep
ON e.employee_id = ep.employee_id
WHERE ep.project_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;

-- 6.	Employees Hired After
SELECT e.first_name, e.last_name, e.hire_date, d.name AS dept_name
FROM employees AS e
JOIN departments AS d
ON d.department_id = e.department_id
WHERE DATE(hire_date) > '1999/01/01' AND d.name IN ('Sales', 'Finance')
ORDER BY hire_date;

-- 07. Employees with Project
SELECT e.employee_id, e.first_name, p.`name` AS project_name
FROM employees AS e
JOIN employees_projects AS ep
ON e.employee_id = ep.employee_id
JOIN projects AS p
ON ep.project_id = p.project_id
WHERE DATE(p.start_date) > '2002/08/13'
AND p.end_date IS NULL
ORDER BY e.first_name, p.name
LIMIT 5;

-- 8.	Employee 24
SELECT e.`employee_id`, e.`first_name`, IF (YEAR(p.`start_date`) >= '2005', NULL, p.`name`)  AS `project_name`
FROM `employees` as e
JOIN `employees_projects` AS ep
ON e.`employee_id` = ep.`employee_id`
JOIN `projects` AS p
ON ep.`project_id` = p.`project_id`
WHERE e.`employee_id` = 24 
ORDER BY `project_name`;

-- 9.	Employee Manager
SELECT e.employee_id, e.first_name, e.manager_id, 
e2.first_name AS manager_name
FROM employees AS e
JOIN employees AS e2
ON  e.manager_id = e2.employee_id
WHERE e.manager_id IN (3,7)
ORDER BY e.first_name;

-- 10.	Employee Summary
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
d.name AS department_name
FROM employees as e
JOIN employees as m
ON m.employee_id = e.manager_id
JOIN departments as d
ON e.department_id = d.department_id
ORDER BY e.employee_id
LIMIT 5;

-- 11.	Min Average Salary
SELECT  AVG(`salary`) AS min_average_salary
FROM employees
GROUP BY department_id
ORDER BY min_average_salary
LIMIT 1;

-- 12.	Highest Peaks in Bulgaria
SELECT mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM mountains_countries AS mc
JOIN mountains AS m
ON m.id = mc.mountain_id
JOIN peaks as p
ON m.id = p.mountain_id
WHERE mc.country_code = 'BG' AND p.elevation > 2835
ORDER BY p.elevation DESC;

-- 13.	Count Mountain Ranges
SELECT c.country_code, COUNT(*) as mountain_range
FROM countries AS c
JOIN mountains_countries AS mc
ON c.country_code = mc.country_code
WHERE c.country_name IN ('United States', 'Russia', 'Bulgaria')
GROUP BY c.country_code
ORDER BY COUNT(*) DESC;
    
    -- 14.	Countries with Rivers
SELECT c.country_name, r.river_name
FROM countries AS c
LEFT JOIN countries_rivers AS rc
ON c.country_code = rc.country_code
LEFT JOIN rivers AS r
ON rc.river_id = r.id
LEFT JOIN continents AS cn
ON c.continent_code = cn.continent_code
WHERE cn.continent_name = 'Africa' 
ORDER BY c.country_name
LIMIT 5;

-- 15.	*Continents and Currencies
SELECT c.continent_code, c.currency_code, COUNT(c.country_name)  AS currency_usage
FROM countries as c
GROUP BY c.continent_code, currency_code
HAVING currency_usage = (
SELECT COUNT(c1.country_code) AS count
FROM countries as c1
WHERE c1.continent_code = c.continent_code
GROUP BY currency_code
ORDER BY count DESC
LIMIT 1
)
AND currency_usage > 1
ORDER BY c.continent_code, c.currency_code;

-- 16.  Countries Without Any Mountains
SELECT COUNT(*) AS country_count
FROM countries AS c
WHERE c.country_code NOT IN (SELECT country_code FROM mountains_countries);

-- 17.  Highest Peak and Longest River by Country
SELECT c.country_name, 
IF(MAX(p.elevation) IS NOT NULL, MAX(p.elevation),NULL)
AS highest_peak_elevation,
IF(MAX(r.length) IS NOT NULL, MAX(r.length),NULL)
AS longest_river_length
FROM countries as c
JOIN mountains_countries as mc
ON c.country_code = mc.country_code
JOIN peaks as p
ON p.mountain_id = mc.mountain_id
JOIN countries_rivers as rc
ON c.country_code = rc.country_code
JOIN rivers as r
ON r.id = rc.river_id
GROUP by c.country_name
ORDER BY highest_peak_elevation DESC, longest_river_length DESC, c.country_name
LIMIT 5;