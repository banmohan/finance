IF OBJECT_ID('finance.eod_required') IS NOT NULL
DROP FUNCTION finance.eod_required;

GO

CREATE FUNCTION finance.eod_required(@office_id integer)
RETURNS bit
AS

BEGIN
    RETURN
    (
	    SELECT finance.fiscal_year.eod_required
	    FROM finance.fiscal_year
	    WHERE finance.fiscal_year.office_id = @office_id
    );
END;



--SELECT finance.eod_required(1);

GO
