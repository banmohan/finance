IF OBJECT_ID('finance.get_account_id_by_account_number') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_account_number;

GO

CREATE FUNCTION finance.get_account_id_by_account_number(@account_number national character varying(500))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        account_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_number=@account_number
	    AND finance.accounts.deleted = 0
	);
END;




GO
