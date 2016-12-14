DROP FUNCTION IF EXISTS finance.get_root_account_id(integer, integer);

CREATE FUNCTION finance.get_root_account_id(_account_id integer, _parent integer default 0)
RETURNS integer
AS
$$
    DECLARE _parent_account_id integer;
BEGIN
    SELECT 
        parent_account_id
        INTO _parent_account_id
    FROM finance.accounts
    WHERE finance.accounts.account_id=$1
	AND NOT finance.accounts.deleted;

    

    IF(_parent_account_id IS NULL) THEN
        RETURN $1;
    ELSE
        RETURN finance.get_root_account_id(_parent_account_id, $1);
    END IF; 
END
$$
LANGUAGE plpgsql;
