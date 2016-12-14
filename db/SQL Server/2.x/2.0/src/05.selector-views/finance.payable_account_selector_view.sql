IF OBJECT_ID('finance.payable_account_selector_view') IS NOT NULL
DROP VIEW finance.payable_account_selector_view;

GO



CREATE VIEW finance.payable_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS payable_account_id,
    finance.account_scrud_view.account_name AS payable_account_name
FROM finance.account_scrud_view
WHERE account_master_id = 15010
ORDER BY account_id;


GO
