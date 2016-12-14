IF OBJECT_ID('finance.has_child_accounts') IS NOT NULL
DROP FUNCTION finance.has_child_accounts;

GO

CREATE FUNCTION finance.has_child_accounts(@account_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS(SELECT 0 FROM finance.accounts WHERE parent_account_id=@account_id LIMIT 1)
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;




GO
