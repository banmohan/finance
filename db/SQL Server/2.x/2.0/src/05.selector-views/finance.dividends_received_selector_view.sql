IF OBJECT_ID('finance.dividends_received_selector_view') IS NOT NULL
DROP VIEW finance.dividends_received_selector_view;

GO


CREATE VIEW finance.dividends_received_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS dividends_received_id,
    finance.account_scrud_view.account_name AS dividends_received_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20301));


GO
