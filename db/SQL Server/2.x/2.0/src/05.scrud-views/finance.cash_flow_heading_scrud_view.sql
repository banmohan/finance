IF OBJECT_ID('finance.cash_flow_heading_scrud_view') IS NOT NULL
DROP VIEW finance.cash_flow_heading_scrud_view;

GO



CREATE VIEW finance.cash_flow_heading_scrud_view
AS
SELECT 
  finance.cash_flow_headings.cash_flow_heading_id, 
  finance.cash_flow_headings.cash_flow_heading_code, 
  finance.cash_flow_headings.cash_flow_heading_name, 
  finance.cash_flow_headings.cash_flow_heading_type, 
  finance.cash_flow_headings.is_debit, 
  finance.cash_flow_headings.is_sales, 
  finance.cash_flow_headings.is_purchase
FROM finance.cash_flow_headings
WHERE finance.cash_flow_headings.deleted = 0;

GO
