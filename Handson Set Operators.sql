-- ============================================================
-- ORACLE SQL SET OPERATORS
-- UNION, UNION ALL, INTERSECT, MINUS
-- ============================================================


-- 1. UNION
-- Combines results from both queries
-- Removes duplicate rows

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE department_id = 50

UNION

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE department_id = 80;


-- ============================================================


-- 2. UNION ALL
-- Combines results from both queries
-- Keeps duplicate rows

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE department_id = 50

UNION ALL

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 5000;


-- ============================================================


-- 3. INTERSECT
-- Returns rows that are common in both queries

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE department_id = 50

INTERSECT

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 5000;


-- ============================================================


-- 4. MINUS
-- Returns rows from the first query
-- that are NOT present in the second query

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE department_id = 50

MINUS

SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 5000;


-- ============================================================
-- SIMPLE EXAMPLES USING DEPARTMENT_ID
-- ============================================================


-- UNION
-- Get departments having employees with salary > 10000
-- OR employees receiving commission
-- Duplicates are removed

SELECT department_id
FROM hr.employees
WHERE salary > 10000

UNION

SELECT department_id
FROM hr.employees
WHERE commission_pct IS NOT NULL;


-- UNION ALL
-- Same as UNION, but duplicates are retained

SELECT department_id
FROM hr.employees
WHERE salary > 10000

UNION ALL

SELECT department_id
FROM hr.employees
WHERE commission_pct IS NOT NULL;


-- INTERSECT
-- Get departments satisfying BOTH conditions

SELECT department_id
FROM hr.employees
WHERE salary > 10000

INTERSECT

SELECT department_id
FROM hr.employees
WHERE commission_pct IS NOT NULL;


-- MINUS
-- Get departments from first query
-- which are not present in second query

SELECT department_id
FROM hr.employees
WHERE salary > 10000

MINUS

SELECT department_id
FROM hr.employees
WHERE commission_pct IS NOT NULL;


-- ============================================================
-- SUMMARY
-- ============================================================

-- UNION
-- Combines two result sets and REMOVES duplicates

-- UNION ALL
-- Combines two result sets and KEEPS duplicates

-- INTERSECT
-- Returns COMMON rows from both result sets

-- MINUS
-- Returns rows from FIRST query that are NOT in SECOND query


-- IMPORTANT RULES:
-- 1. Both SELECT statements must have the same number of columns.
-- 2. Corresponding columns must have compatible data types.
-- 3. Column order should match between the queries.
-- 4. ORDER BY should normally be written only at the end.