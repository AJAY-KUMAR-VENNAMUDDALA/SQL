-- Employees whose salary is between 5000 and 10000
SELECT *
FROM hr.employees
WHERE salary BETWEEN 5000 AND 10000;

-- Employees whose salary is NOT between 5000 and 10000
SELECT *
FROM hr.employees
WHERE salary NOT BETWEEN 5000 AND 10000;




-- Employees belonging to departments 10, 20, 30 or 50
SELECT *
FROM hr.employees
WHERE department_id IN (10, 20, 30, 50);

-- Employees not belonging to these departments
SELECT *
FROM hr.employees
WHERE department_id NOT IN (10, 20, 30, 50);



--===============Like  % zero or more occurances
--exactly one chracter


-- First name starts with S
SELECT *
FROM hr.employees
WHERE first_name LIKE 'S%';

-- First name ends with n
SELECT *
FROM hr.employees
WHERE first_name LIKE '%n';

-- First name contains 'an'
SELECT *
FROM hr.employees
WHERE first_name LIKE '%an%';

-- Second character is 'a'
SELECT *
FROM hr.employees
WHERE first_name LIKE '_a%';

-- Names that do not start with S
SELECT *
FROM hr.employees
WHERE first_name NOT LIKE 'S%';