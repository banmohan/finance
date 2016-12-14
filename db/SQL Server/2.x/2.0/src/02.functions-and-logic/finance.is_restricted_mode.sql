IF OBJECT_ID('finance.is_restricted_mode') IS NOT NULL
DROP FUNCTION finance.is_restricted_mode;

GO

CREATE FUNCTION finance.is_restricted_mode()
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT TOP 1 0 FROM finance.day_operation
        WHERE completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;



GO
