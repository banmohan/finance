IF OBJECT_ID('finance.is_new_day_started') IS NOT NULL
DROP FUNCTION finance.is_new_day_started;

GO

CREATE FUNCTION finance.is_new_day_started(@office_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT TOP 1 0 FROM finance.day_operation
        WHERE finance.day_operation.office_id = @office_id
        AND finance.day_operation.completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;

--SELECT * FROM finance.is_new_day_started(1);

GO
