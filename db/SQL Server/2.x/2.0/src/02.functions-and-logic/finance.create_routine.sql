IF OBJECT_ID('finance.create_routine') IS NOT NULL
DROP PROCEDURE finance.create_routine;

GO

CREATE PROCEDURE finance.create_routine(@routine_code national character varying(12), @routine national character varying(128), @order integer)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS(SELECT * FROM finance.routines WHERE routine_code=@routine_code)
    BEGIN
        INSERT INTO finance.routines(routine_code, routine_name, "order")
        SELECT @routine_code, @routine, @order
        RETURN;
    END;

    UPDATE finance.routines
    SET
        routine_name = @routine,
        "order" = @order
    WHERE routine_code=@routine_code;
END;

GO
