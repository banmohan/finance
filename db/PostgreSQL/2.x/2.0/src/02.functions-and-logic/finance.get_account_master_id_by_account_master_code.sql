DROP FUNCTION IF EXISTS finance.get_account_master_id_by_account_master_code(text);

CREATE FUNCTION finance.get_account_master_id_by_account_master_code(_account_master_code text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN finance.account_masters.account_master_id
    FROM finance.account_masters
    WHERE finance.account_masters.account_master_code = $1
	AND NOT finance.account_masters.deleted;
END
$$
LANGUAGE plpgsql;

