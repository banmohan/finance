IF OBJECT_ID('finance.get_account_master_id_by_account_master_code') IS NOT NULL
DROP FUNCTION finance.get_account_master_id_by_account_master_code;

GO

CREATE FUNCTION finance.get_account_master_id_by_account_master_code(@account_master_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT finance.account_masters.account_master_id
	    FROM finance.account_masters
	    WHERE finance.account_masters.account_master_code = @account_master_code
	    AND finance.account_masters.deleted = 0
    );
END;





GO
