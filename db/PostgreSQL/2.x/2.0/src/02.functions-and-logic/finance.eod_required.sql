DROP FUNCTION IF EXISTS finance.eod_required(_office_id integer);

CREATE FUNCTION finance.eod_required(_office_id integer)
RETURNS boolean
AS
$$
BEGIN
    RETURN finance.fiscal_year.eod_required
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.office_id = _office_id;
END
$$
LANGUAGE plpgsql;

--SELECT finance.eod_required(1);