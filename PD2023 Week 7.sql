WITH TRANSACTIONS_CTE AS(
SELECT
    TP.TRANSACTION_ID,
    ACCOUNT_TO,
    ACCOUNT_FROM,
    TRANSACTION_DATE,
    VALUE,
    CANCELLED_
FROM PD2023_WK07_TRANSACTION_PATH AS TP
INNER JOIN PD2023_WK07_TRANSACTION_DETAIL AS TD
    ON TP.TRANSACTION_ID = TD.TRANSACTION_ID
WHERE CANCELLED_ = 'N'
    AND VALUE > 1000
), --Creating a CTE that has all the transactions stuff and details together

ACCOUNT_INFO AS (
SELECT
    ACCOUNT_NUMBER,
    ACCOUNT_TYPE,
    TRIM(VALUE) AS ACCOUNT_HOLDER_ID_2,
    BALANCE_DATE,
    BALANCE
FROM PD2023_WK07_ACCOUNT_INFORMATION, LATERAL SPLIT_TO_TABLE(ACCOUNT_HOLDER_ID, ',')
WHERE ACCOUNT_TYPE != 'Platinum'
), --CTE that splits the joint account holder id's into rows and filtering out the platinum accounts

ACCOUNT_HOLD AS (
SELECT
    ACCOUNT_HOLDER_ID,
    NAME,
    DATE_OF_BIRTH,
    CONCAT('07',TO_VARCHAR(CONTACT_NUMBER)) AS CONTACT_NUMBER_2,
    FIRST_LINE_OF_ADDRESS
FROM PD2023_WK07_ACCOUNT_HOLDERS
), --CTE where 07 is added to the contact numbers

ACCOUNT_JOINED AS (
SELECT
    ACCOUNT_HOLDER_ID,
    ACCOUNT_NUMBER,
    ACCOUNT_TYPE,
    BALANCE_DATE,
    BALANCE,
    NAME,
    DATE_OF_BIRTH,
    CONTACT_NUMBER_2,
    FIRST_LINE_OF_ADDRESS
FROM ACCOUNT_INFO AS AI
INNER JOIN ACCOUNT_HOLD AS AH
    ON AI.ACCOUNT_HOLDER_ID_2 = AH.ACCOUNT_HOLDER_ID
) -- joining together all the account details together
SELECT
    T.TRANSACTION_ID AS "Transaction ID",
    T.ACCOUNT_TO AS "Account To",
    T.TRANSACTION_DATE AS "Transaction Date",
    T.VALUE as "Value",
    AJ.ACCOUNT_NUMBER "Account Number",
    AJ.ACCOUNT_TYPE AS "Account Type",
    AJ.BALANCE_DATE AS "Balance Date" ,
    AJ.NAME AS "Name",
    AJ.DATE_OF_BIRTH AS "Date of Birth",
    AJ.CONTACT_NUMBER_2 AS "Contact Number",
    AJ.FIRST_LINE_OF_ADDRESS AS "First Line of Address"
FROM TRANSACTIONS_CTE AS T
INNER JOIN ACCOUNT_JOINED AS AJ
    ON T.ACCOUNT_FROM = AJ.ACCOUNT_NUMBER
;
-- Final Join





