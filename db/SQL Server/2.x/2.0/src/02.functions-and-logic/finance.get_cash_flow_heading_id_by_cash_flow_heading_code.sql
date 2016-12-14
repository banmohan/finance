IF OBJECT_ID('finance.get_cash_flow_heading_id_by_cash_flow_heading_code') IS NOT NULL
DROP FUNCTION finance.get_cash_flow_heading_id_by_cash_flow_heading_code;

GO

CREATE FUNCTION finance.get_cash_flow_heading_id_by_cash_flow_heading_code(@cash_flow_heading_code national character varying(12))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        cash_flow_heading_id
	    FROM finance.cash_flow_headings
	    WHERE finance.cash_flow_headings.cash_flow_heading_code = @cash_flow_heading_code
	    AND finance.cash_flow_headings.deleted = 0
	);
END;




GO
