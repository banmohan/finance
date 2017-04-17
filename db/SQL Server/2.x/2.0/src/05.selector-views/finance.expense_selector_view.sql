IF OBJECT_ID('finance.expense_selector_view') IS NOT NULL
DROP VIEW finance.expense_selector_view;

GO

CREATE VIEW finance.expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS expense_id,
    finance.account_scrud_view.account_name AS expense_name
FROM finance.account_scrud_view
WHERE account_master_id > 20400;

GO
