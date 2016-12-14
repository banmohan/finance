IF OBJECT_ID('finance.get_account_id_by_account_name') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_account_name;

GO

CREATE FUNCTION finance.get_account_id_by_account_name(@account_name national character varying(500))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        account_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_name=@account_name
	    AND finance.accounts.deleted = 0
	);
END;




GO
