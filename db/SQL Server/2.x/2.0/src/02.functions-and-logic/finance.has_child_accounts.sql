IF OBJECT_ID('finance.has_child_accounts') IS NOT NULL
DROP FUNCTION finance.has_child_accounts;

GO

CREATE FUNCTION finance.has_child_accounts(@account_id integer)
RETURNS bit
AS
BEGIN
	DECLARE @has_child bit = 0;

    IF EXISTS(SELECT TOP 1 0 FROM finance.accounts WHERE parent_account_id=@account_id)
    BEGIN
        SET @has_child = 1;
    END;

    RETURN @has_child;
END;

GO
