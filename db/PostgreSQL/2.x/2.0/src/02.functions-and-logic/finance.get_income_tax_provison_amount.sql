DROP FUNCTION IF EXISTS finance.get_income_tax_provison_amount(_office_id integer, _profit  numeric(30, 6), _balance  numeric(30, 6));

CREATE FUNCTION finance.get_income_tax_provison_amount(_office_id integer, _profit numeric(30, 6), _balance numeric(30, 6))
RETURNS  numeric(30, 6)
AS
$$
    DECLARE _rate real;
BEGIN
    _rate := finance.get_income_tax_rate(_office_id);

    IF(_profit <= 0) THEN
    	RETURN 0;
    END IF;

    RETURN
    (
        (_profit * _rate/100) - _balance
    );
END
$$
LANGUAGE plpgsql;
