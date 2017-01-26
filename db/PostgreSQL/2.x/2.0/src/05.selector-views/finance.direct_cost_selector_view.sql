DROP VIEW IF EXISTS finance.direct_cost_selector_view;

CREATE VIEW finance.direct_cost_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS direct_cost_id,
    finance.account_scrud_view.account_name AS direct_cost_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20500))
ORDER BY account_id;


