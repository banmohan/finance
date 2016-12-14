IF OBJECT_ID('finance.is_eod_initialized') IS NOT NULL
DROP FUNCTION finance.is_eod_initialized;

GO

CREATE FUNCTION finance.is_eod_initialized(@office_id integer, @value_date date)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT * FROM finance.day_operation
        WHERE office_id = @office_id
        AND value_date = @value_date
        AND completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;




--SELECT * FROM finance.is_eod_initialized(1, '1-1-2000');

GO
