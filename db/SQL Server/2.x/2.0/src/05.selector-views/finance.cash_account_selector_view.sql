IF OBJECT_ID('finance.cash_account_selector_view') IS NOT NULL
DROP VIEW finance.cash_account_selector_view;

GO

CREATE VIEW finance.cash_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS cash_account_id,
    finance.account_scrud_view.account_name AS cash_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10101));

GO
