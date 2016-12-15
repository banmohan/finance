-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_second_root_account_id.sql --<--<--
IF OBJECT_ID('finance.get_second_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_second_root_account_id;

GO

CREATE FUNCTION finance.get_second_root_account_id(@account_id integer, @parent bigint)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;
    DECLARE @root_account_id integer;

    SELECT @parent_account_id =  parent_account_id
    FROM finance.accounts
    WHERE account_id=@account_id;

    IF(@parent_account_id IS NULL)
    BEGIN
        SET @root_account_id =  @parent;
    END
    ELSE
    BEGIN
        SET @root_account_id = finance.get_second_root_account_id(@parent_account_id, @account_id);
    END;

    RETURN @root_account_id;
END;

GO
