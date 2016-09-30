DROP FUNCTION IF EXISTS finance.has_child_accounts(bigint);

CREATE FUNCTION finance.has_child_accounts(bigint)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS(SELECT 0 FROM finance.accounts WHERE parent_account_id=$1 LIMIT 1) THEN
        RETURN true;
    END IF;

    RETURN false;
END
$$
LANGUAGE plpgsql;
