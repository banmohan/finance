IF OBJECT_ID('finance.shareholders_equity_selector_view') IS NOT NULL
DROP VIEW finance.shareholders_equity_selector_view;

GO


CREATE VIEW finance.shareholders_equity_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS shareholders_equity_id,
    finance.account_scrud_view.account_name AS shareholders_equity_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15200));


GO
