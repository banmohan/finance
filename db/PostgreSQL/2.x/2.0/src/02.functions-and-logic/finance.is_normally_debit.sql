DROP FUNCTION IF EXISTS finance.is_normally_debit(_account_id bigint);

CREATE FUNCTION finance.is_normally_debit(_account_id bigint)
RETURNS boolean
AS
$$
BEGIN
    RETURN
        finance.account_masters.normally_debit
    FROM  finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
    WHERE account_id = $1;
END
$$
LANGUAGE plpgsql;