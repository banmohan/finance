IF OBJECT_ID('finance.is_cash_account_id') IS NOT NULL
DROP FUNCTION finance.is_cash_account_id;

GO

CREATE FUNCTION finance.is_cash_account_id(@account_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT 1 FROM finance.accounts 
        WHERE account_master_id IN(10101)
        AND account_id=@account_id
    )
    BEGIN
        RETURN 1;
    END;
    RETURN 0;
END;

GO

