IF OBJECT_ID('finance.get_income_tax_provison_amount') IS NOT NULL
DROP FUNCTION finance.get_income_tax_provison_amount;

GO

CREATE FUNCTION finance.get_income_tax_provison_amount(@office_id integer, @profit numeric(30, 6), @balance numeric(30, 6))
RETURNS  numeric(30, 6)
AS
BEGIN
    DECLARE @rate real = finance.get_income_tax_rate(@office_id);

    IF(@profit <= 0)
    BEGIN
    	RETURN 0;
    END;

    RETURN
    (
        (@profit * @rate/100) - @balance
    );
END;

GO