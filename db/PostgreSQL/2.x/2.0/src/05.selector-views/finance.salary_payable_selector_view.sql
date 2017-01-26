DROP VIEW IF EXISTS finance.salary_payable_selector_view;

CREATE VIEW finance.salary_payable_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS salary_payable_id,
    finance.account_scrud_view.account_name AS salary_payable_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15011))
ORDER BY account_id;
