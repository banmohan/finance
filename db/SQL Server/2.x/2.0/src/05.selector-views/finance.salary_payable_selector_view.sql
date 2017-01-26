IF OBJECT_ID('finance.salary_payable_selector_view') IS NOT NULL
DROP VIEW finance.salary_payable_selector_view;

GO


CREATE VIEW finance.salary_payable_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS salary_payable_id,
    finance.account_scrud_view.account_name AS salary_payable_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15011));


GO
