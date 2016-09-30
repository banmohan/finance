DROP VIEW IF EXISTS finance.cash_flow_setup_scrud_view;

CREATE VIEW finance.cash_flow_setup_scrud_view
AS
SELECT 
    finance.cash_flow_setup.cash_flow_setup_id, 
    finance.cash_flow_headings.cash_flow_heading_code || '('|| finance.cash_flow_headings.cash_flow_heading_name||')' AS cash_flow_heading, 
    finance.account_masters.account_master_code || '('|| finance.account_masters.account_master_name||')' AS account_master
FROM finance.cash_flow_setup
INNER JOIN finance.cash_flow_headings
ON  finance.cash_flow_setup.cash_flow_heading_id =finance.cash_flow_headings.cash_flow_heading_id
INNER JOIN finance.account_masters
ON finance.cash_flow_setup.account_master_id = finance.account_masters.account_master_id
WHERE NOT finance.cash_flow_setup.deleted;
