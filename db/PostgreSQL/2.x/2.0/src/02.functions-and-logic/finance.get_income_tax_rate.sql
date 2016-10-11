DROP FUNCTION IF EXISTS finance.get_income_tax_rate(_office_id integer);

CREATE FUNCTION finance.get_income_tax_rate(_office_id integer)
RETURNS public.decimal_strict
AS
$$
BEGIN
    RETURN income_tax_rate
    FROM finance.tax_setups
    WHERE finance.tax_setups.office_id = _office_id
    AND NOT finance.tax_setups.deleted;
        
END
$$
LANGUAGE plpgsql;