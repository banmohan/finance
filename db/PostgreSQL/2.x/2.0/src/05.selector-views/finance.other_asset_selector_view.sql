DROP VIEW IF EXISTS finance.other_asset_selector_view;

CREATE VIEW finance.other_asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS other_asset_id,
    finance.account_scrud_view.account_name AS other_asset_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10300))
ORDER BY account_id;

