IF OBJECT_ID('finance.get_account_name_by_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_name_by_account_id;

GO

CREATE FUNCTION finance.get_account_name_by_account_id(@account_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT account_name
	    FROM finance.accounts
	    WHERE finance.accounts.account_id=@account_id
	    AND finance.accounts.deleted = 0
    );
END;




GO
