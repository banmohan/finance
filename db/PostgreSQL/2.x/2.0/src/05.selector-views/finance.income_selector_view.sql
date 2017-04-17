DROP VIEW IF EXISTS finance.income_selector_view;

CREATE VIEW finance.income_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS income_id,
    finance.account_scrud_view.account_name AS income_name
FROM finance.account_scrud_view
WHERE account_master_id BETWEEN 20100 AND 20399
ORDER BY account_id;

