IF OBJECT_ID('finance.get_sales_tax_rate') IS NOT NULL
DROP FUNCTION finance.get_sales_tax_rate;

GO

CREATE FUNCTION finance.get_sales_tax_rate(@office_id integer)
RETURNS numeric(30, 6)
AS
BEGIN
	RETURN
	(
		SELECT 
			finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.office_id = @office_id
	);
END;

GO
