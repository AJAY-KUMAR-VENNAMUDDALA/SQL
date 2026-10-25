-- 1. Display all employee records
SELECT *
FROM HR.EMPLOYEES;


-- 2. Display employee first names
SELECT FIRST_NAME
FROM HR.EMPLOYEES;


-- 3. Display first name and last name
SELECT FIRST_NAME, LAST_NAME
FROM HR.EMPLOYEES;

-- Where Clause ---------------------------------------

-- 5. Display employees earning more than 5000
SELECT *
FROM HR.EMPLOYEES
WHERE SALARY > 5000;


-- 6. Display employees earning less than 10000
SELECT *
FROM HR.EMPLOYEES
WHERE SALARY < 10000;


-- 7. Display employees earning exactly 6000
SELECT *
FROM HR.EMPLOYEES
WHERE SALARY = 6000;


-- 8. Display employees from department 50
SELECT *
FROM HR.EMPLOYEES
WHERE DEPARTMENT_ID = 50;


-- 9. Display employees with job ID SA_REP
SELECT *
FROM HR.EMPLOYEES
WHERE JOB_ID = 'SA_REP';


-- 10. Display employees whose first name is Steven
SELECT *
FROM HR.EMPLOYEES
WHERE FIRST_NAME = 'Steven';

---- Group by -------------------------------------

-- 1. Count employees in each department
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID;


-- 2. Find average salary in each department
SELECT DEPARTMENT_ID, AVG(SALARY) AS AVG_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID;


-- 3. Find maximum salary in each department
SELECT DEPARTMENT_ID, MAX(SALARY) AS MAX_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID;


-- 4. Find minimum salary in each department
SELECT DEPARTMENT_ID, MIN(SALARY) AS MIN_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID;


-- 5. Find total salary paid by each department
SELECT DEPARTMENT_ID, SUM(SALARY) AS TOTAL_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID;


-- 6. Count employees for each job
SELECT JOB_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM HR.EMPLOYEES
GROUP BY JOB_ID;

-- 1. Count employees by department and job
SELECT DEPARTMENT_ID, JOB_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID, JOB_ID;


-- 2. Average salary by department and job
SELECT DEPARTMENT_ID, JOB_ID, AVG(SALARY) AS AVG_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID, JOB_ID;


-- 3. Total salary by department and job
SELECT DEPARTMENT_ID, JOB_ID, SUM(SALARY) AS TOTAL_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID, JOB_ID;


-- Having ----

-- 1. Departments having more than 5 employees
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING COUNT(*) > 5;


-- 2. Departments having average salary greater than 8000
SELECT DEPARTMENT_ID, AVG(SALARY) AS AVG_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING AVG(SALARY) > 8000;


-- 3. Departments having total salary greater than 50000
SELECT DEPARTMENT_ID, SUM(SALARY) AS TOTAL_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING SUM(SALARY) > 50000;


-- 4. Departments having maximum salary greater than 15000
SELECT DEPARTMENT_ID, MAX(SALARY) AS MAX_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING MAX(SALARY) > 15000;


-- 5. Departments having minimum salary less than 5000
SELECT DEPARTMENT_ID, MIN(SALARY) AS MIN_SALARY
FROM HR.EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING MIN(SALARY) < 5000;


-- 6. Jobs having more than 3 employees
SELECT JOB_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM HR.EMPLOYEES
GROUP BY JOB_ID
HAVING COUNT(*) > 3;