IF OBJECT_ID('finance.get_account_master_ids') IS NOT NULL
DROP FUNCTION finance.get_account_master_ids;

GO

CREATE FUNCTION finance.get_account_master_ids(@root_account_master_id integer)
RETURNS @result TABLE
(
    account_master_id              integer
)
AS
BEGIN
    WITH account_cte(account_master_id, path) AS 
    (
        SELECT
            tn.account_master_id,  CAST(tn.account_master_id AS varchar(2000)) AS path
        FROM finance.account_masters AS tn 
        WHERE tn.account_master_id = @root_account_master_id
        AND tn.deleted = 0

        UNION ALL

        SELECT
            c.account_master_id, CAST((p.path + '->' + CAST(c.account_master_id AS varchar(50))) AS varchar(2000))
        FROM account_cte AS p, finance.account_masters AS c WHERE parent_account_master_id = p.account_master_id
    )

    INSERT INTO @result
    SELECT account_master_id FROM account_cte
    RETURN;
END;
GO

--SELECT * FROM finance.get_account_master_ids(1);

