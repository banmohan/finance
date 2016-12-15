
CREATE FUNCTION finance.get_account_ids(@root_account_id integer)
RETURNS @result TABLE
(
    account_id              integer
)
AS
BEGIN
        WITH account_cte(account_id, path) AS 
        (
            SELECT
                tn.account_id,  tn.account_id AS path
            FROM finance.accounts AS tn 
            WHERE tn.account_id = @root_account_id
            AND tn.deleted = 0

            UNION ALL

            SELECT
                c.account_id, (p.path + '->' + c.account_id)
            FROM account_cte AS p, finance.accounts AS c WHERE parent_account_id = p.account_id
        )

    INSERT INTO @result
    SELECT account_id FROM account_cte
    RETURN;
END;




GO
