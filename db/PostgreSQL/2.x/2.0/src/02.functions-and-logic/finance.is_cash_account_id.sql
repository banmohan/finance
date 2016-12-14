DROP FUNCTION IF EXISTS finance.is_cash_account_id(_account_id integer);

CREATE FUNCTION finance.is_cash_account_id(_account_id integer)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS
    (
        SELECT 1 FROM finance.accounts 
        WHERE account_master_id IN(10101)
        AND account_id=_account_id
    ) THEN
        RETURN true;
    END IF;
    RETURN false;
END
$$
LANGUAGE plpgsql;


