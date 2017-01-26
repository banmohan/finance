IF OBJECT_ID('finance.current_liability_selector_view') IS NOT NULL
DROP VIEW finance.current_liability_selector_view;

GO


CREATE VIEW finance.current_liability_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS current_liability_id,
    finance.account_scrud_view.account_name AS current_liability_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15000));


GO
