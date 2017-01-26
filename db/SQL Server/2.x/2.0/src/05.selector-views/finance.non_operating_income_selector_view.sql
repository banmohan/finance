IF OBJECT_ID('finance.non_operating_income_selector_view') IS NOT NULL
DROP VIEW finance.non_operating_income_selector_view;

GO


CREATE VIEW finance.non_operating_income_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS non_operating_income_id,
    finance.account_scrud_view.account_name AS non_operating_income_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20200));


GO
