IF OBJECT_ID('finance.get_account_id_by_bank_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_bank_account_id;

GO

CREATE FUNCTION finance.get_account_id_by_bank_account_id(@bank_account_id integer)
RETURNS integer
AS
BEGIN
	RETURN
	(
		SELECT account_id 
		FROM finance.bank_accounts
		WHERE bank_account_id = @bank_account_id
		AND deleted = 0
	);
END;

GO

--SELECT finance.get_account_id_by_bank_account_id(1);

