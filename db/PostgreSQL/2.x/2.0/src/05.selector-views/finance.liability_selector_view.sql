DROP VIEW IF EXISTS finance.liability_selector_view;

CREATE VIEW finance.liability_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS liability_id,
    finance.account_scrud_view.account_name AS liability_name
FROM finance.account_scrud_view
WHERE account_master_id BETWEEN 15000 AND 19999
ORDER BY account_id;
