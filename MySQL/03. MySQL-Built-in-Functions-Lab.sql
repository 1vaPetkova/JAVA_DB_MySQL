-- Lab
-- 1.	Find Book Titles
SELECT `title` 
FROM `books`
WHERE SUBSTR(`title`,1 , 3) = 'The'; 

-- 2.	Replace Titles
SELECT REPLACE (`title`,'The', '***') 
FROM `books`
WHERE SUBSTR(`title`,1 , 3) = 'The'; 

-- 3.	Sum Cost of All Books
SELECT ROUND(SUM(`cost`), 2) AS `sum` 
FROM `books`;

-- 4.	Days Lived
SELECT CONCAT_WS(' ',`first_name`,`last_name`) AS 'Full name',
TIMESTAMPDIFF(DAY, `born`,`died`) AS `Days lived`
FROM `authors`;

-- 5. Harry Potter Books
SELECT `title` 
FROM `books`
WHERE `title` LIKE 'Harry Potter%';
