IF OBJECT_ID('finance.income_tax_expense_selector_view') IS NOT NULL
DROP VIEW finance.income_tax_expense_selector_view;

GO


CREATE VIEW finance.income_tax_expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS income_tax_expense_id,
    finance.account_scrud_view.account_name AS income_tax_expense_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20800));

GO

