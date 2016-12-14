IF OBJECT_ID('finance.get_income_tax_provison_amount') IS NOT NULL
DROP FUNCTION finance.get_income_tax_provison_amount;

GO

CREATE FUNCTION finance.get_income_tax_provison_amount(@office_id integer, @profit decimal(24, 4), @balance decimal(24, 4))
RETURNS  decimal(24, 4)
AS
BEGIN
    DECLARE @rate real;

    @rate = finance.get_income_tax_rate(@office_id);

    RETURN
    (
        (@profit * @rate/100) - @balance
    );
END;




GO
