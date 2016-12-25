DROP FUNCTION IF EXISTS finance.get_account_ids(root_account_id integer);

CREATE FUNCTION finance.get_account_ids(root_account_id integer)
RETURNS SETOF integer
STABLE
AS
$$
BEGIN
    RETURN QUERY 
    (
        WITH RECURSIVE account_cte(account_id, path) AS (
         SELECT
            tn.account_id,  tn.account_id::TEXT AS path
            FROM finance.accounts AS tn 
			WHERE tn.account_id =$1
			AND NOT tn.deleted
        UNION ALL
         SELECT
            c.account_id, (p.path || '->' || c.account_id::TEXT)
            FROM account_cte AS p, finance.accounts AS c WHERE parent_account_id = p.account_id
        )

        SELECT account_id FROM account_cte
    );
END
$$LANGUAGE plpgsql;

