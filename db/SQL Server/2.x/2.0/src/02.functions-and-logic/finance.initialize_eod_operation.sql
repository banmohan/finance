IF OBJECT_ID('finance.initialize_eod_operation') IS NOT NULL
DROP PROCEDURE finance.initialize_eod_operation;

GO

CREATE PROCEDURE finance.initialize_eod_operation(@user_id integer, @office_id integer, @value_date date)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF(@value_date IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 13, 1);
    END;

    IF(account.is_admin(@user_id) = 0)
    BEGIN
        RAISERROR('Access is denied.', 13, 1);
    END;

    IF(@value_date != finance.get_value_date(@office_id))
    BEGIN
        RAISERROR('Invalid value date.', 13, 1);
    END;


    IF NOT EXISTS
    (
        SELECT * FROM finance.day_operation
        WHERE value_date=@value_date
        AND office_id = @office_id
    )
    BEGIN
        INSERT INTO finance.day_operation(office_id, value_date, started_on, started_by)
        SELECT @office_id, @value_date, GETUTCDATE(), @user_id;
    END
    ELSE    
    BEGIN
        RAISERROR('EOD operation was already initialized.', 13, 1);
    END;

    RETURN;
END;

GO
