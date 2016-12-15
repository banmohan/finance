IF OBJECT_ID('finance.get_account_master_id_by_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_master_id_by_account_id;

GO

CREATE FUNCTION finance.get_account_master_id_by_account_id(@account_id integer)
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT finance.accounts.account_master_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_id=@account_id
	    AND finance.accounts.deleted = 0
    );
END;

GO

ALTER TABLE finance.bank_accounts
ADD CONSTRAINT bank_accounts_account_id_chk 
CHECK
(
    finance.get_account_master_id_by_account_id(account_id) = '10102'
);

GO
