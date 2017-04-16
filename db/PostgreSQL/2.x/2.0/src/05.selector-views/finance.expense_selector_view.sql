DROP VIEW IF EXISTS finance.expense_selector_view;

CREATE VIEW finance.expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS expense_id,
    finance.account_scrud_view.account_name AS expense_name
FROM finance.account_scrud_view
WHERE account_master_id > 20400
ORDER BY account_id;
