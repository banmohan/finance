IF OBJECT_ID('finance.cost_of_sale_selector_view') IS NOT NULL
DROP VIEW finance.cost_of_sale_selector_view;

GO


CREATE VIEW finance.cost_of_sale_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS cost_of_sale_id,
    finance.account_scrud_view.account_name AS cost_of_sale_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20400));


GO
