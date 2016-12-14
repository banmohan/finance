IF OBJECT_ID('finance.convert_exchange_rate') IS NOT NULL
DROP FUNCTION finance.convert_exchange_rate;

GO

CREATE FUNCTION finance.convert_exchange_rate(@office_id integer, @source_currency_code national character varying(12), @destination_currency_code national character varying(12))
RETURNS dbo.decimal_strict2
AS
BEGIN
    DECLARE @unit                           dbo.integer_strict2 = 0;
    DECLARE @exchange_rate                  dbo.decimal_strict2 = 0;
    DECLARE @from_source_currency           dbo.decimal_strict2 = finance.get_exchange_rate(@office_id, @source_currency_code);
    DECLARE @from_destination_currency      dbo.decimal_strict2 = finance.get_exchange_rate(@office_id, @destination_currency_code);

    IF(@source_currency_code = @destination_currency_code)
    BEGIN
        RETURN 1;
    END;
        
    RETURN @from_source_currency / @from_destination_currency ; 
END;

--SELECT * FROM  finance.convert_exchange_rate(1, 'USD', 'NPR')


GO