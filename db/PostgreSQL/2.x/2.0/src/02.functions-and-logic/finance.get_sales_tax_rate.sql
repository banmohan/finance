DROP FUNCTION IF EXISTS finance.get_sales_tax_rate(_office_id integer);

CREATE FUNCTION finance.get_sales_tax_rate(_office_id integer)
RETURNS numeric(30, 6)
AS
$$
BEGIN
	RETURN
	(
		SELECT 
			finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.office_id = _office_id
	);
END
$$
LANGUAGE plpgsql;
