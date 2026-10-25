-- ============================================================
-- ORACLE SQL BASIC DATE FUNCTIONS - 20 EXAMPLES
-- Table: HR.EMPLOYEES
-- ============================================================


-- ============================================================
-- 1. SYSDATE
-- BUSINESS QUESTION:
-- Display each employee's hire date and today's date.
-- ============================================================

SELECT first_name,
       hire_date,
       SYSDATE AS current_date
FROM hr.employees;


-- ============================================================
-- 2. ADD_MONTHS() - ADD 6 MONTHS
-- BUSINESS QUESTION:
-- What is the date 6 months after each employee joined?
-- ============================================================

SELECT first_name,
       hire_date,
       ADD_MONTHS(hire_date, 6) AS after_6_months
FROM hr.employees;


-- ============================================================
-- 3. ADD_MONTHS() - ADD 12 MONTHS
-- BUSINESS QUESTION:
-- When does each employee complete one year?
-- ============================================================

SELECT first_name,
       hire_date,
       ADD_MONTHS(hire_date, 12) AS one_year_completion
FROM hr.employees;


-- ============================================================
-- 4. ADD_MONTHS() - ADD 24 MONTHS
-- BUSINESS QUESTION:
-- When does each employee complete two years?
-- ============================================================

SELECT first_name,
       hire_date,
       ADD_MONTHS(hire_date, 24) AS two_year_completion
FROM hr.employees;


-- ============================================================
-- 5. ADD_MONTHS() - SUBTRACT 6 MONTHS
-- BUSINESS QUESTION:
-- What was the date 6 months before each employee joined?
-- ============================================================

SELECT first_name,
       hire_date,
       ADD_MONTHS(hire_date, -6) AS six_months_before
FROM hr.employees;


-- ============================================================
-- 6. MONTHS_BETWEEN()
-- BUSINESS QUESTION:
-- How many months has each employee worked?
-- ============================================================

SELECT first_name,
       hire_date,
       MONTHS_BETWEEN(SYSDATE, hire_date) AS months_worked
FROM hr.employees;


-- ============================================================
-- 7. MONTHS_BETWEEN() - YEARS
-- BUSINESS QUESTION:
-- How many years has each employee worked?
-- Result may contain decimal values.
-- ============================================================

SELECT first_name,
       hire_date,
       MONTHS_BETWEEN(SYSDATE, hire_date) / 12 AS years_worked
FROM hr.employees;


-- ============================================================
-- 8. LAST_DAY()
-- BUSINESS QUESTION:
-- What was the last day of the month in which
-- each employee joined?
-- ============================================================

SELECT first_name,
       hire_date,
       LAST_DAY(hire_date) AS last_day_of_month
FROM hr.employees;


-- ============================================================
-- 9. NEXT_DAY() - MONDAY
-- BUSINESS QUESTION:
-- What was the next Monday after each employee joined?
-- ============================================================

SELECT first_name,
       hire_date,
       NEXT_DAY(hire_date, 'MONDAY') AS next_monday
FROM hr.employees;


-- ============================================================
-- 10. NEXT_DAY() - FRIDAY
-- BUSINESS QUESTION:
-- What was the next Friday after each employee joined?
-- ============================================================

SELECT first_name,
       hire_date,
       NEXT_DAY(hire_date, 'FRIDAY') AS next_friday
FROM hr.employees;


-- ============================================================
-- 11. TRUNC()
-- BUSINESS QUESTION:
-- Remove the time component from today's date.
-- ============================================================

SELECT first_name,
       hire_date,
       TRUNC(SYSDATE) AS today
FROM hr.employees;


-- ============================================================
-- 12. TRUNC() - MONTH
-- BUSINESS QUESTION:
-- Find the first day of the employee's joining month.
-- ============================================================

SELECT first_name,
       hire_date,
       TRUNC(hire_date, 'MONTH') AS first_day_of_month
FROM hr.employees;


-- ============================================================
-- 13. TRUNC() - YEAR
-- BUSINESS QUESTION:
-- Find the first day of the employee's joining year.
-- ============================================================

SELECT first_name,
       hire_date,
       TRUNC(hire_date, 'YEAR') AS first_day_of_year
FROM hr.employees;


-- ============================================================
-- 14. TO_CHAR() - FORMAT DATE
-- BUSINESS QUESTION:
-- Display hire date in DD-MM-YYYY format.
-- ============================================================

SELECT first_name,
       hire_date,
       TO_CHAR(hire_date, 'DD-MM-YYYY') AS formatted_hire_date
FROM hr.employees;


-- ============================================================
-- 15. TO_CHAR() - MONTH NAME
-- BUSINESS QUESTION:
-- Display the month name in which each employee joined.
-- ============================================================

SELECT first_name,
       hire_date,
       TO_CHAR(hire_date, 'MONTH') AS joining_month
FROM hr.employees;


-- ============================================================
-- 16. TO_CHAR() - DAY NAME
-- BUSINESS QUESTION:
-- Display the day of the week on which each employee joined.
-- ============================================================

SELECT first_name,
       hire_date,
       TO_CHAR(hire_date, 'DAY') AS joining_day
FROM hr.employees;


-- ============================================================
-- 17. ADD DAYS
-- BUSINESS QUESTION:
-- What is the date 30 days after each employee joined?
-- In Oracle, DATE + number adds days.
-- ============================================================

SELECT first_name,
       hire_date,
       hire_date + 30 AS after_30_days
FROM hr.employees;


-- ============================================================
-- 18. SUBTRACT DAYS
-- BUSINESS QUESTION:
-- What was the date 30 days before each employee joined?
-- In Oracle, DATE - number subtracts days.
-- ============================================================

SELECT first_name,
       hire_date,
       hire_date - 30 AS before_30_days
FROM hr.employees;


-- ============================================================
-- 19. DIFFERENCE BETWEEN TWO DATES
-- BUSINESS QUESTION:
-- How many days has each employee worked?
-- DATE - DATE returns the difference in days.
-- ============================================================

SELECT first_name,
       hire_date,
       TRUNC(SYSDATE) - TRUNC(hire_date) AS days_worked
FROM hr.employees;


-- ============================================================
-- 20. TO_DATE()
-- BUSINESS QUESTION:
-- Find employees who joined after 1st January 2005.
-- TO_DATE converts character data into DATE.
-- ============================================================

SELECT first_name,
       hire_date
FROM hr.employees
WHERE hire_date > TO_DATE('01-01-2005', 'DD-MM-YYYY');