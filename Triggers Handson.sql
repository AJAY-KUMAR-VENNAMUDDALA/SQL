-- ============================================================
-- BANKING SYSTEM - ORACLE PL/SQL TRIGGERS
-- ============================================================
-- TABLE 1: BANK_ACCOUNTS
-- TABLE 2: BANK_AUDIT_LOG
--
-- TRIGGERS:
-- 1. BEFORE INSERT
-- 2. AFTER INSERT
-- 3. BEFORE UPDATE
-- 4. AFTER UPDATE
-- 5. BEFORE DELETE
-- 6. AFTER DELETE
-- ============================================================


-- ============================================================
-- STEP 1: CREATE BANK ACCOUNTS TABLE
-- ============================================================

CREATE TABLE BANK_ACCOUNTS (

    ACCOUNT_ID NUMBER PRIMARY KEY,       -- Unique bank account ID

    CUSTOMER_NAME VARCHAR2(100),         -- Customer name

    ACCOUNT_TYPE VARCHAR2(20),           -- Savings or Current

    BALANCE NUMBER(12,2),                -- Available account balance

    STATUS VARCHAR2(20),                 -- ACTIVE or INACTIVE

    CREATED_DATE DATE DEFAULT SYSDATE    -- Account creation date

);


-- ============================================================
-- STEP 2: CREATE BANK AUDIT LOG TABLE
-- ============================================================

CREATE TABLE BANK_AUDIT_LOG (

    LOG_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- Automatically generates a unique log ID

    ACCOUNT_ID NUMBER,
    -- Stores the affected bank account ID

    ACTION_TYPE VARCHAR2(30),
    -- Stores INSERT, UPDATE or DELETE action

    OLD_BALANCE NUMBER(12,2),
    -- Stores balance before modification

    NEW_BALANCE NUMBER(12,2),
    -- Stores balance after modification

    DESCRIPTION VARCHAR2(200),
    -- Stores information about the action

    ACTION_DATE DATE DEFAULT SYSDATE
    -- Stores date and time of the action

);


-- ============================================================
-- TRIGGER 1: BEFORE INSERT
-- ============================================================
-- BUSINESS SCENARIO:
-- A bank should not allow accounts with negative opening balance.
-- If the customer does not provide a balance, set it to zero.
-- Set the account status to ACTIVE if not provided.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_BEFORE_INSERT

BEFORE INSERT ON BANK_ACCOUNTS
-- Execute before a new account is inserted

FOR EACH ROW
-- Execute once for every inserted row

BEGIN

    -- Set opening balance to zero if NULL
    IF :NEW.BALANCE IS NULL THEN

        :NEW.BALANCE := 0;

    END IF;

    -- Check whether opening balance is negative
    IF :NEW.BALANCE < 0 THEN

        -- Reject account creation
        RAISE_APPLICATION_ERROR(
            -20001,
            'Opening balance cannot be negative'
        );

    END IF;

    -- Set default account status
    IF :NEW.STATUS IS NULL THEN

        :NEW.STATUS := 'ACTIVE';

    END IF;

END;
/


-- ============================================================
-- TRIGGER 2: AFTER INSERT
-- ============================================================
-- BUSINESS SCENARIO:
-- Whenever a customer opens a bank account,
-- automatically record the activity in the audit table.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_AFTER_INSERT

AFTER INSERT ON BANK_ACCOUNTS
-- Execute after an account is inserted

FOR EACH ROW
-- Execute once for every inserted row

BEGIN

    -- Insert account creation information into audit table
    INSERT INTO BANK_AUDIT_LOG (

        ACCOUNT_ID,       -- Newly created account ID

        ACTION_TYPE,      -- Action performed

        OLD_BALANCE,      -- Previous balance

        NEW_BALANCE,      -- Opening balance

        DESCRIPTION       -- Audit message

    )

    VALUES (

        :NEW.ACCOUNT_ID,  -- New account ID

        'INSERT',         -- Insert operation

        NULL,             -- No previous balance

        :NEW.BALANCE,     -- New account balance

        'New bank account created'

    );

END;
/


-- ============================================================
-- TRIGGER 3: BEFORE UPDATE
-- ============================================================
-- BUSINESS SCENARIO:
-- Customers should not withdraw more money than available.
-- Reject an update if it produces a negative balance.
-- Also prevent changes to an inactive account's balance.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_BEFORE_UPDATE

BEFORE UPDATE ON BANK_ACCOUNTS
-- Execute before updating an existing account

FOR EACH ROW
-- Execute once for every updated row

BEGIN

    -- Check whether new balance is negative
    IF :NEW.BALANCE < 0 THEN

        -- Reject the update
        RAISE_APPLICATION_ERROR(
            -20002,
            'Insufficient bank balance'
        );

    END IF;

    -- Check whether an inactive account balance is changing
    IF :OLD.STATUS = 'INACTIVE'
       AND :NEW.BALANCE <> :OLD.BALANCE THEN

        -- Reject balance changes on inactive accounts
        RAISE_APPLICATION_ERROR(
            -20003,
            'Cannot modify balance of inactive account'
        );

    END IF;

END;
/


-- ============================================================
-- TRIGGER 4: AFTER UPDATE
-- ============================================================
-- BUSINESS SCENARIO:
-- Whenever the account balance changes,
-- automatically store the old and new balances.
-- This helps the bank track deposits and withdrawals.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_AFTER_UPDATE

AFTER UPDATE ON BANK_ACCOUNTS
-- Execute after an account is updated

FOR EACH ROW
-- Execute once for every updated row

BEGIN

    -- Log only when the balance actually changes
    IF :OLD.BALANCE <> :NEW.BALANCE THEN

        -- Insert balance modification into audit table
        INSERT INTO BANK_AUDIT_LOG (

            ACCOUNT_ID,      -- Account being updated

            ACTION_TYPE,     -- Update operation

            OLD_BALANCE,     -- Balance before update

            NEW_BALANCE,     -- Balance after update

            DESCRIPTION      -- Audit message

        )

        VALUES (

            :NEW.ACCOUNT_ID, -- Updated account ID

            'UPDATE',        -- Update action

            :OLD.BALANCE,    -- Previous balance

            :NEW.BALANCE,    -- Current balance

            'Bank account balance updated'

        );

    END IF;

END;
/


-- ============================================================
-- TRIGGER 5: BEFORE DELETE
-- ============================================================
-- BUSINESS SCENARIO:
-- A bank should not delete an account containing money.
-- Allow deletion only when the account balance is zero.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_BEFORE_DELETE

BEFORE DELETE ON BANK_ACCOUNTS
-- Execute before deleting a bank account

FOR EACH ROW
-- Execute once for every deleted row

BEGIN

    -- Check whether account still contains money
    IF :OLD.BALANCE <> 0 THEN

        -- Stop the deletion
        RAISE_APPLICATION_ERROR(
            -20004,
            'Cannot delete account with non-zero balance'
        );

    END IF;

END;
/


-- ============================================================
-- TRIGGER 6: AFTER DELETE
-- ============================================================
-- BUSINESS SCENARIO:
-- When a bank account is deleted,
-- save its details in the audit log for future reference.
-- ============================================================

CREATE OR REPLACE TRIGGER TRG_BANK_AFTER_DELETE

AFTER DELETE ON BANK_ACCOUNTS
-- Execute after the account is deleted

FOR EACH ROW
-- Execute once for every deleted row

BEGIN

    -- Store deleted account details in audit table
    INSERT INTO BANK_AUDIT_LOG (

        ACCOUNT_ID,      -- Deleted account ID

        ACTION_TYPE,     -- Delete operation

        OLD_BALANCE,     -- Balance before deletion

        NEW_BALANCE,     -- Balance after deletion

        DESCRIPTION      -- Audit message

    )

    VALUES (

        :OLD.ACCOUNT_ID, -- Deleted account ID

        'DELETE',        -- Delete action

        :OLD.BALANCE,    -- Previous balance

        NULL,            -- Account no longer exists

        'Bank account deleted'

    );

END;
/


-- ============================================================
-- STEP 3: TEST BEFORE INSERT AND AFTER INSERT
-- ============================================================

-- Create account for Rahul with opening balance 10000
INSERT INTO BANK_ACCOUNTS
(ACCOUNT_ID, CUSTOMER_NAME, ACCOUNT_TYPE, BALANCE)
VALUES
(101, 'Rahul', 'SAVINGS', 10000);


-- Create account for Priya with opening balance 20000
INSERT INTO BANK_ACCOUNTS
(ACCOUNT_ID, CUSTOMER_NAME, ACCOUNT_TYPE, BALANCE)
VALUES
(102, 'Priya', 'SAVINGS', 20000);


-- Create account for Amit with zero balance
INSERT INTO BANK_ACCOUNTS
(ACCOUNT_ID, CUSTOMER_NAME, ACCOUNT_TYPE, BALANCE)
VALUES
(103, 'Amit', 'CURRENT', 0);


-- Save inserted accounts and audit records
COMMIT;


-- View all bank accounts
SELECT * FROM BANK_ACCOUNTS;


-- View account creation logs
SELECT * FROM BANK_AUDIT_LOG
ORDER BY LOG_ID;


-- ============================================================
-- STEP 4: TEST BEFORE INSERT VALIDATION
-- ============================================================

-- Attempt to create account with negative balance
-- BEFORE INSERT trigger rejects this operation
-- Expected error: ORA-20001
-- Run separately after testing successful inserts

/*
INSERT INTO BANK_ACCOUNTS
(ACCOUNT_ID, CUSTOMER_NAME, ACCOUNT_TYPE, BALANCE)
VALUES
(104, 'Kiran', 'SAVINGS', -5000);
*/


-- ============================================================
-- STEP 5: TEST BEFORE UPDATE AND AFTER UPDATE
-- ============================================================

-- Deposit 5000 into Rahul's account
UPDATE BANK_ACCOUNTS

SET BALANCE = BALANCE + 5000

WHERE ACCOUNT_ID = 101;


-- Withdraw 3000 from Priya's account
UPDATE BANK_ACCOUNTS

SET BALANCE = BALANCE - 3000

WHERE ACCOUNT_ID = 102;


-- Save successful balance changes
COMMIT;


-- Check updated account balances
SELECT ACCOUNT_ID, CUSTOMER_NAME, BALANCE
FROM BANK_ACCOUNTS;


-- Check balance update audit logs
SELECT * FROM BANK_AUDIT_LOG
WHERE ACTION_TYPE = 'UPDATE'
ORDER BY LOG_ID;


-- ============================================================
-- STEP 6: TEST BEFORE UPDATE VALIDATION
-- ============================================================

-- Attempt to withdraw more than the available balance
-- BEFORE UPDATE trigger prevents negative balance
-- Expected error: ORA-20002
-- Run separately

/*
UPDATE BANK_ACCOUNTS

SET BALANCE = BALANCE - 50000

WHERE ACCOUNT_ID = 101;
*/


-- ============================================================
-- STEP 7: TEST BEFORE DELETE VALIDATION
-- ============================================================

-- Attempt to delete Rahul's account
-- Rahul still has 15000 balance
-- BEFORE DELETE trigger rejects deletion
-- Expected error: ORA-20004
-- Run separately

/*
DELETE FROM BANK_ACCOUNTS
WHERE ACCOUNT_ID = 101;
*/


-- ============================================================
-- STEP 8: TEST BEFORE DELETE AND AFTER DELETE
-- ============================================================

-- Amit has zero balance
-- BEFORE DELETE trigger allows the operation
DELETE FROM BANK_ACCOUNTS

WHERE ACCOUNT_ID = 103;


-- AFTER DELETE trigger records deletion in audit table
COMMIT;


-- Check remaining accounts
SELECT * FROM BANK_ACCOUNTS;


-- Check deleted account audit record
SELECT * FROM BANK_AUDIT_LOG
WHERE ACTION_TYPE = 'DELETE';


-- ============================================================
-- STEP 9: FINAL VERIFICATION
-- ============================================================

-- View all remaining bank accounts
SELECT
    ACCOUNT_ID,
    CUSTOMER_NAME,
    ACCOUNT_TYPE,
    BALANCE,
    STATUS
FROM BANK_ACCOUNTS
ORDER BY ACCOUNT_ID;


-- View complete banking audit history
SELECT
    LOG_ID,
    ACCOUNT_ID,
    ACTION_TYPE,
    OLD_BALANCE,
    NEW_BALANCE,
    DESCRIPTION,
    ACTION_DATE
FROM BANK_AUDIT_LOG
ORDER BY LOG_ID;


-- ============================================================
-- STEP 10: VERIFY ALL SIX TRIGGERS
-- ============================================================

-- Display trigger names and status
SELECT
    TRIGGER_NAME,
    TRIGGER_TYPE,
    TRIGGERING_EVENT,
    STATUS
FROM USER_TRIGGERS
WHERE TABLE_NAME = 'BANK_ACCOUNTS'
ORDER BY TRIGGER_NAME;


-- ============================================================
-- END OF BANKING TRIGGER EXAMPLE
-- ============================================================