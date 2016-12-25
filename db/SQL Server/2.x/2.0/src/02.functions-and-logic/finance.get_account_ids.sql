IF OBJECT_ID('finance.get_account_ids') IS NOT NULL
DROP FUNCTION finance.get_account_ids;

GO

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
            tn.account_id,  CAST(tn.account_id AS varchar(2000)) AS path
        FROM finance.accounts AS tn 
        WHERE tn.account_id = @root_account_id
        AND tn.deleted = 0

        UNION ALL

        SELECT
            c.account_id, CAST((p.path + '->' + CAST(c.account_id AS varchar(50))) AS varchar(2000))
        FROM account_cte AS p, finance.accounts AS c WHERE parent_account_id = p.account_id
    )

    INSERT INTO @result
    SELECT account_id FROM account_cte
    RETURN;
END;
GO

--SELECT * FROM finance.get_account_ids(1);

