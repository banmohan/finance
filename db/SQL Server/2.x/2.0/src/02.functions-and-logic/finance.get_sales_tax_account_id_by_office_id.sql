IF OBJECT_ID('finance.get_sales_tax_account_id_by_office_id') IS NOT NULL
DROP FUNCTION finance.get_sales_tax_account_id_by_office_id;

GO

CREATE FUNCTION finance.get_sales_tax_account_id_by_office_id(@office_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT finance.tax_setups.sales_tax_account_id
	    FROM finance.tax_setups
	    WHERE finance.tax_setups.deleted = 0
	    AND finance.tax_setups.office_id = @office_id
    );
END



GO
