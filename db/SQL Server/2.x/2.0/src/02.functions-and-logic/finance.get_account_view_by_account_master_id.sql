IF OBJECT_ID('finance.get_account_view_by_account_master_id') IS NOT NULL
DROP FUNCTION finance.get_account_view_by_account_master_id;

GO

CREATE FUNCTION finance.get_account_view_by_account_master_id
(
    @account_master_id      integer,
    @row_number             integer
)
RETURNS @results table
(
    id                      bigint,
    account_id              integer,
    account_name            text    
)
AS
BEGIN
    INSERT INTO @results
    SELECT ROW_NUMBER() OVER (ORDER BY accounts.account_id) + @row_number AS id, * FROM 
    (
        SELECT 
			finance.accounts.account_id, 
			finance.get_account_name_by_account_id(finance.accounts.account_id) AS account_name
        FROM finance.accounts
        WHERE finance.accounts.account_master_id = @account_master_id
    ) AS accounts;    
	
	RETURN;
END;

GO
