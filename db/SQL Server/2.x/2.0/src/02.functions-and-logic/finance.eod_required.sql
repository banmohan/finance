IF OBJECT_ID('finance.eod_required') IS NOT NULL
DROP FUNCTION finance.eod_required;

GO

CREATE FUNCTION finance.eod_required(@office_id integer)
RETURNS bit
AS
BEGIN
	DECLARE @value_date date = finance.get_value_date(@office_id);

    RETURN
    (
	    SELECT finance.fiscal_year.eod_required
	    FROM finance.fiscal_year
	    WHERE finance.fiscal_year.office_id = @office_id
		AND finance.fiscal_year.deleted = 0
		AND finance.fiscal_year.starts_from >= @value_date
		AND finance.fiscal_year.ends_on <= @value_date
    );
END;

GO

--SELECT finance.eod_required(1);
