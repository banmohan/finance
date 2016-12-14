IF OBJECT_ID('finance.is_normally_debit') IS NOT NULL
DROP FUNCTION finance.is_normally_debit;

GO

CREATE FUNCTION finance.is_normally_debit(@account_id integer)
RETURNS bit
AS

BEGIN
    RETURN
    (
	    SELECT
	        finance.account_masters.normally_debit
	    FROM  finance.accounts
	    INNER JOIN finance.account_masters
	    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
	    WHERE finance.accounts.account_id = @account_id
	    AND finance.accounts.deleted = 0
	);
END



GO
