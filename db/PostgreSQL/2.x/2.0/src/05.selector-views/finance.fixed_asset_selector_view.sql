DROP VIEW IF EXISTS finance.fixed_asset_selector_view;

CREATE VIEW finance.fixed_asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS fixed_asset_id,
    finance.account_scrud_view.account_name AS fixed_asset_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10200))
ORDER BY account_id;
