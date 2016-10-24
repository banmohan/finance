DROP FUNCTION IF EXISTS finance.get_account_master_id_by_account_id(bigint) CASCADE;

CREATE FUNCTION finance.get_account_master_id_by_account_id(bigint)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN finance.accounts.account_master_id
    FROM finance.accounts
    WHERE finance.accounts.account_id= $1
	AND NOT finance.accounts.deleted;
END
$$
LANGUAGE plpgsql;

ALTER TABLE finance.bank_accounts
ADD CONSTRAINT bank_accounts_account_id_chk 
CHECK
(
    finance.get_account_master_id_by_account_id(account_id) = '10102'
);