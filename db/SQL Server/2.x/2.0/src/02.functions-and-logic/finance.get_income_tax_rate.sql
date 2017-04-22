IF OBJECT_ID('finance.get_income_tax_rate') IS NOT NULL
DROP FUNCTION finance.get_income_tax_rate;

GO

CREATE FUNCTION finance.get_income_tax_rate(@office_id integer)
RETURNS numeric(30, 6)
AS

BEGIN
    RETURN
    (
	    SELECT income_tax_rate
	    FROM finance.tax_setups
	    WHERE finance.tax_setups.office_id = @office_id
	    AND finance.tax_setups.deleted = 0
    );    
END;



GO
