-- ============================================================
-- ORACLE SQL + PL/SQL
-- SLOWLY CHANGING DIMENSIONS (SCD)
--
-- TYPE 0 = RETAIN ORIGINAL VALUE
-- TYPE 1 = OVERWRITE
-- TYPE 2 = ADD NEW ROW / FULL HISTORY
-- TYPE 3 = CURRENT + PREVIOUS VALUE
-- TYPE 4 = CURRENT TABLE + SEPARATE HISTORY TABLE

-- ============================================================

SET SERVEROUTPUT ON;


-- ############################################################
-- SCD TYPE 0
-- ############################################################
--
-- Type 0 = Original value never changes.
--
-- Example:
-- Customer's original registration city = Bangalore
--
-- Even if customer moves to Hyderabad,
-- original city remains Bangalore.
-- ############################################################


CREATE TABLE customer_scd0
(
    customer_id       NUMBER PRIMARY KEY,
    customer_name     VARCHAR2(50),
    registration_city VARCHAR2(50)
);


INSERT INTO customer_scd0
VALUES (101, 'Arjun', 'Bangalore');

COMMIT;


-- Type 0 normally does NOT update the historical attribute.
-- Procedure only displays the permanent/original information.

CREATE OR REPLACE PROCEDURE show_customer_scd0
(
    p_customer_id IN NUMBER
)
AS

    v_name VARCHAR2(50);
    v_city VARCHAR2(50);

BEGIN

    SELECT customer_name,
           registration_city

    INTO v_name,
         v_city

    FROM customer_scd0

    WHERE customer_id = p_customer_id;


    DBMS_OUTPUT.PUT_LINE(
        'Customer = ' || v_name
    );

    DBMS_OUTPUT.PUT_LINE(
        'Original Registration City = ' || v_city
    );

END;
/


BEGIN
    show_customer_scd0(101);
END;
/


-- RESULT:
--
-- Customer = Arjun
-- Original Registration City = Bangalore
--
-- TYPE 0:
-- Never change original information.


-- ############################################################
-- SCD TYPE 1
-- ############################################################
--
-- TYPE 1 = OVERWRITE
--
-- Bangalore -> Hyderabad
--
-- Bangalore is lost.
-- ############################################################


CREATE TABLE customer_scd1
(
    customer_id   NUMBER PRIMARY KEY,
    customer_name VARCHAR2(50),
    city          VARCHAR2(50)
);


INSERT INTO customer_scd1
VALUES (101, 'Arjun', 'Bangalore');

COMMIT;


CREATE OR REPLACE PROCEDURE update_customer_scd1
(
    p_customer_id IN NUMBER,
    p_new_city    IN VARCHAR2
)
AS
BEGIN

    UPDATE customer_scd1

    SET city = p_new_city

    WHERE customer_id = p_customer_id;


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        'SCD Type 1 Updated'
    );

END;
/


BEGIN

    update_customer_scd1(
        101,
        'Hyderabad'
    );

END;
/


SELECT *
FROM customer_scd1;


-- RESULT:
--
-- 101 | Arjun | Hyderabad
--
-- Bangalore lost.
--
-- TYPE 1 = NO HISTORY


-- ############################################################
-- SCD TYPE 2
-- ############################################################
--
-- TYPE 2 = FULL HISTORY
--
-- Bangalore
--    ↓
-- Hyderabad
--    ↓
-- Pune
--
-- Every version becomes a separate row.
-- ############################################################


CREATE TABLE customer_scd2
(
    customer_key   NUMBER PRIMARY KEY,
    customer    NUMBER,
    customer_name  VARCHAR2(50),
    city           VARCHAR2(50),
    start_date     DATE,
    end_date       DATE,
    current_flag   VARCHAR2(1)
);


CREATE SEQUENCE customer_scd2_seq
START WITH 1
INCREMENT BY 1;


INSERT INTO customer_scd2
VALUES
(
    customer_scd2_seq.NEXTVAL,
    101,
    'Arjun',
    'Bangalore',
    TO_DATE('01-01-2026','DD-MM-YYYY'),
    NULL,
    'Y'
);

COMMIT;


CREATE OR REPLACE PROCEDURE update_customer_scd2
(
    p_customer_id   IN NUMBER,
    p_customer_name IN VARCHAR2,
    p_new_city      IN VARCHAR2,
    p_change_date   IN DATE
)
AS
BEGIN

    -- Close current record

    UPDATE customer_scd2

    SET end_date = p_change_date - 1,
        current_flag = 'N'

    WHERE customer_id = p_customer_id
      AND current_flag = 'Y';


    -- Insert new version

    INSERT INTO customer_scd2
    (
        customer_key,
        customer_id,
        customer_name,
        city,
        start_date,
        end_date,
        current_flag
    )

    VALUES
    (
        customer_scd2_seq.NEXTVAL,
        p_customer_id,
        p_customer_name,
        p_new_city,
        p_change_date,
        NULL,
        'Y'
    );


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        'SCD Type 2 History Created'
    );

END;
/


-- Bangalore -> Hyderabad

BEGIN

    update_customer_scd2(
        101,
        'Arjun',
        'Hyderabad',
        TO_DATE('01-04-2026','DD-MM-YYYY')
    );

END;
/


-- Hyderabad -> Pune

BEGIN

    update_customer_scd2(
        101,
        'Arjun',
        'Pune',
        TO_DATE('01-08-2026','DD-MM-YYYY')
    );

END;
/


SELECT *
FROM customer_scd2
ORDER BY customer_key;


-- RESULT:
--
-- Arjun | Bangalore | Jan-Mar | N
-- Arjun | Hyderabad | Apr-Jul | N
-- Arjun | Pune      | Aug-    | Y
--
-- TYPE 2 = FULL HISTORY


-- ############################################################
-- SCD TYPE 3
-- ############################################################
--
-- TYPE 3:
--
-- Current value + previous value
--
-- Current City
-- Previous City
-- ############################################################


CREATE TABLE customer_scd3
(
    customer_id   NUMBER PRIMARY KEY,
    customer_name VARCHAR2(50),
    current_city  VARCHAR2(50),
    previous_city VARCHAR2(50)
);


INSERT INTO customer_scd3
VALUES
(
    101,
    'Arjun',
    'Bangalore',
    NULL
);

COMMIT;


CREATE OR REPLACE PROCEDURE update_customer_scd3
(
    p_customer_id IN NUMBER,
    p_new_city    IN VARCHAR2
)
AS
BEGIN

    UPDATE customer_scd3

    SET previous_city = current_city,
        current_city = p_new_city

    WHERE customer_id = p_customer_id;


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        'SCD Type 3 Updated'
    );

END;
/


-- Bangalore -> Hyderabad

BEGIN

    update_customer_scd3(
        101,
        'Hyderabad'
    );

END;
/


SELECT *
FROM customer_scd3;


-- RESULT:
--
-- Arjun | Hyderabad | Bangalore


-- Hyderabad -> Pune

BEGIN

    update_customer_scd3(
        101,
        'Pune'
    );

END;
/


SELECT *
FROM customer_scd3;


-- RESULT:
--
-- Arjun | Pune | Hyderabad
--
-- TYPE 3 = LIMITED HISTORY


-- ############################################################
-- SCD TYPE 4
-- ############################################################
--
-- TYPE 4:
--
-- TWO TABLES
--
-- CUSTOMER_CURRENT
--        +
-- CUSTOMER_HISTORY
--
-- Current information remains in one table.
-- Historical information goes into another table.
-- ############################################################


CREATE TABLE customer_current
(
    customer_id   NUMBER PRIMARY KEY,
    customer name VARCHAR2(50),
    city          VARCHAR2(50)
);


CREATE TABLE customer_history
(
    history_id    NUMBER PRIMARY KEY,
    customer_id   NUMBER,
    customer_name VARCHAR2(50),
    old_city      VARCHAR2(50),
    change_date   DATE
);


CREATE SEQUENCE customer_history_seq
START WITH 1
INCREMENT BY 1;


INSERT INTO customer_current
VALUES
(
    101,
    'Arjun',
    'Bangalore'
);

COMMIT;


CREATE OR REPLACE PROCEDURE update_customer_scd4
(
    p_customer_id IN NUMBER,
    p_new_city    IN VARCHAR2
)
AS

    v_name     VARCHAR2(50);
    v_old_city VARCHAR2(50);

BEGIN

    -- Get current information

    SELECT customer_name,
           city

    INTO v_name,
         v_old_city

    FROM customer_current

    WHERE customer_id = p_customer_id;


    -- Store OLD value in history table

    INSERT INTO customer_history
    (
        history_id,
        customer_id,
        customer_name,
        old_city,
        change_date
    )

    VALUES
    (
        customer_history_seq.NEXTVAL,
        p_customer_id,
        v_name,
        v_old_city,
        SYSDATE
    );


    -- Update current table

    UPDATE customer_current

    SET city = p_new_city

    WHERE customer_id = p_customer_id;


    COMMIT;


    DBMS_OUTPUT.PUT_LINE(
        'SCD Type 4 Updated'
    );

END;
/


-- Bangalore -> Hyderabad

BEGIN

    update_customer_scd4(
        101,
        'Hyderabad'
    );

END;
/


-- Hyderabad -> Pune

BEGIN

    update_customer_scd4(
        101,
        'Pune'
    );

END;
/


-- CURRENT DATA

SELECT *
FROM customer_current;


-- HISTORY

SELECT *
FROM customer_history
ORDER BY history_id;


-- CURRENT TABLE:
--
-- Arjun | Pune
--
--
-- HISTORY TABLE:
--
-- Arjun | Bangalore
-- Arjun | Hyderabad
--
--
-- TYPE 4:
--
-- CURRENT TABLE
-- +
-- HISTORY TABLE