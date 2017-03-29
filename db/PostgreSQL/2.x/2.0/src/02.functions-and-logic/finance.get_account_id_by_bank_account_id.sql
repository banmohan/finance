DROP FUNCTION IF EXISTS finance.get_account_id_by_bank_account_id(_bank_account_id integer);

CREATE FUNCTION finance.get_account_id_by_bank_account_id(_bank_account_id integer)
RETURNS integer
AS
$$
BEGIN
	RETURN
	(
		SELECT account_id 
		FROM finance.bank_accounts
		WHERE bank_account_id = _bank_account_id
		AND deleted = false
	);
END
$$
LANGUAGE plpgsql;


--SELECT finance.get_account_id_by_bank_account_id(1);

