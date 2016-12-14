IF OBJECT_ID('finance.get_second_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_second_root_account_id;

GO

CREATE FUNCTION finance.get_second_root_account_id(@account_id integer, @parent bigint default 0)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;

    SELECT 
        parent_account_id
        INTO @parent_account_id
    FROM finance.accounts
    WHERE account_id=@account_id;

    IF(@parent_account_id IS NULL)
    BEGIN
        RETURN @parent;
    END
    ELSE
    BEGIN
        RETURN finance.get_second_root_account_id(@parent_account_id, @account_id);
    END; 
END;





GO
