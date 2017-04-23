IF OBJECT_ID('finance.get_exchange_rate') IS NOT NULL
DROP FUNCTION finance.get_exchange_rate;

GO

CREATE FUNCTION finance.get_exchange_rate(@office_id integer, @currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @local_currency_code        national character varying(12)= '';
    DECLARE @unit                       integer = 0;
    DECLARE @exchange_rate              numeric(30, 6) = 0;

    SELECT @local_currency_code = core.offices.currency_code
    FROM core.offices
    WHERE core.offices.office_id=@office_id
    AND core.offices.deleted = 0;

    IF(@local_currency_code = @currency_code)
    BEGIN
        RETURN 1;
    END;

    SELECT 
        @unit = unit, 
        @exchange_rate = exchange_rate
    FROM finance.exchange_rate_details
    INNER JOIN finance.exchange_rates
    ON finance.exchange_rate_details.exchange_rate_id = finance.exchange_rates.exchange_rate_id
    WHERE finance.exchange_rates.office_id=@office_id
    AND foreign_currency_code=@currency_code;

    IF(@unit = 0)
    BEGIN
        RETURN 0;
    END;
    
    RETURN @exchange_rate/@unit;    
END;

GO
