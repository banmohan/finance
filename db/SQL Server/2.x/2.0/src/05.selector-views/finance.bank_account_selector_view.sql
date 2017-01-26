IF OBJECT_ID('finance.bank_account_selector_view') IS NOT NULL
DROP VIEW finance.bank_account_selector_view;

GO

CREATE VIEW finance.bank_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS bank_account_id,
    finance.account_scrud_view.account_name AS bank_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10102));


GO
