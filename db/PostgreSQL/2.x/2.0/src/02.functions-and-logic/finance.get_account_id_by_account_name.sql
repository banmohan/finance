DROP FUNCTION IF EXISTS finance.get_account_id_by_account_name(text);

CREATE FUNCTION finance.get_account_id_by_account_name(text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN
		account_id
    FROM finance.accounts
    WHERE finance.accounts.account_name=$1
	AND NOT finance.accounts.deleted;
END
$$
LANGUAGE plpgsql;
