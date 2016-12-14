DROP FUNCTION IF EXISTS finance.is_normally_debit(_account_id integer);

CREATE FUNCTION finance.is_normally_debit(_account_id integer)
RETURNS boolean
AS
$$
BEGIN
    RETURN
        finance.account_masters.normally_debit
    FROM  finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
    WHERE finance.accounts.account_id = $1
	AND NOT finance.accounts.deleted;
END
$$
LANGUAGE plpgsql;