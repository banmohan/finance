IF OBJECT_ID('finance.get_frequency_setup_start_date_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS
BEGIN
    DECLARE @start_date date;

    SELECT @start_date = DATEADD(day, 1, MAX(value_date)) 
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date < 
    (
        SELECT value_date
        FROM finance.frequency_setups
        WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@start_date IS NULL)
    BEGIN
        SELECT @start_date = starts_from 
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @start_date;
END;

GO
