DROP FUNCTION IF EXISTS finance.eod_required(_office_id integer);

CREATE FUNCTION finance.eod_required(_office_id integer)
RETURNS boolean
AS
$$
    DECLARE _value_date     date = finance.get_value_date(_office_id);
BEGIN
    RETURN finance.fiscal_year.eod_required
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.office_id = _office_id
    AND NOT finance.fiscal_year.deleted
    AND finance.fiscal_year.starts_from >= _value_date
    AND finance.fiscal_year.ends_on <= _value_date;
END
$$
LANGUAGE plpgsql;

--SELECT finance.eod_required(1);

