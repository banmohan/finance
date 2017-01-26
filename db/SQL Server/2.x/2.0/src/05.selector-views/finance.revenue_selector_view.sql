IF OBJECT_ID('finance.revenue_selector_view') IS NOT NULL
DROP VIEW finance.revenue_selector_view;

GO


CREATE VIEW finance.revenue_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS revenue_id,
    finance.account_scrud_view.account_name AS revenue_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20100));

GO
