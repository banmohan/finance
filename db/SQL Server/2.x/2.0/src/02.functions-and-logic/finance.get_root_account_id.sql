IF OBJECT_ID('finance.get_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_root_account_id;

GO

CREATE FUNCTION finance.get_root_account_id(@account_id integer, @parent bigint default 0)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;

    SELECT 
        parent_account_id
        INTO @parent_account_id
    FROM finance.accounts
    WHERE finance.accounts.account_id=@account_id
    AND finance.accounts.deleted = 0;

    

    IF(@parent_account_id IS NULL)
    BEGIN
        RETURN @account_id;
    ELSE
    BEGIN
        RETURN finance.get_root_account_id(@parent_account_id, @account_id);
    END; 
END;




GO
