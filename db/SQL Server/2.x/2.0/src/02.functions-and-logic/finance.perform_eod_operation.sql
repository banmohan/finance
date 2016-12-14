IF OBJECT_ID('finance.perform_eod_operation') IS NOT NULL
DROP PROCEDURE finance.perform_eod_operation;


CREATE PROCEDURE finance.perform_eod_operation(@user_id integer, @login_id bigint, @office_id integer, @value_date date)
AS
BEGIN
    DECLARE @routine            national character varying(128);
    DECLARE @routine_id         integer;
    DECLARE @sql                national character varying(1000);
    DECLARE @is_error           bit= 0;
    DECLARE @notice             national character varying(1000);
    DECLARE @office_code        national character varying(50);
    DECLARE @this               TABLE
    (
        routine_id              integer,
        routine_name            national character varying(128)
    );
    DECLARE @counter            integer = 0;
    DECLARE @total_rows         integer = 0;


    IF(@value_date IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 10, 1);
    END;

    IF(NOT account.is_admin(@user_id))
    BEGIN
        RAISERROR('Access is denied.', 10, 1);
    END;

    IF(@value_date != finance.get_value_date(@office_id))
    BEGIN
        RAISERROR('Invalid value date.', 10, 1);
    END;

    SELECT * FROM finance.day_operation
    WHERE value_date=_value_date 
    AND office_id = @office_id INTO this;

    IF(this IS NULL)
    BEGIN
        RAISERROR('Invalid value date.', 10, 1);
    END
    ELSE
    BEGIN    
        IF(this.completed OR this.completed_on IS NOT NULL)
        BEGIN
            RAISERROR('End of day operation was already performed.', 10, 1);
            @is_error        = 1;
        END;
    END;

    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE value_date < @value_date
        AND verification_status_id = 0
    )
    BEGIN
        RAISERROR('Past dated transactions in verification queue.', 10, 1);
        @is_error        = 1;
    END;

    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE value_date = @value_date
        AND verification_status_id = 0
    )
    BEGIN
        RAISERROR('Please verify transactions before performing end of day operation.', 10, 1);
        @is_error        = 1;
    END;
    
    IF(NOT @is_error)
    BEGIN
        INSERT INTO @this
        SELECT routine_id, routine_name 
        FROM finance.routines 
        WHERE status = 1
        ORDER BY "order" ASC;

        @office_code        = core.get_office_code_by_office_id(@office_id);
        @notice             = 'EOD started.';
        PRINT @notice;

        SELECT @total_rows=MAX(routine_id) FROM @this;

        WHILE @counter<@total_rows
        BEGIN
            SELECT TOP 1 
                @routine_id = routine_id,
                @routine = routine_name 
            FROM @this
            WHERE routine_id >= @counter
            ORDER BY routine_id;

            PRINT @ROUTINE_ID;  

            IF(@routine_id IS NOT NULL)
            BEGIN
                SET @counter=@routine_id +1;        
            END
            ELSE
            BEGIN
                BREAK;
            END;

            @sql                    = FORMATMESSAGE('EXECUTE %s @user_id, @login_id, @office_id, @value_date;', @routine);

            PRINT @sql;

            @notice             = 'Performing ' + @routine + '.';
            PRINT @notice;

            WAITFOR DELAY '00:00:02';
            EXECUTE @sql USING @user_id, @login_id, @office_id, @value_date;

            @notice             = 'Completed  ' + @routine + '.';
            PRINT @notice;
            
            WAITFOR DELAY '00:00:02';
        END;




        UPDATE finance.day_operation SET 
            completed_on = GETDATE(), 
            completed_by = @user_id,
            completed = 1
        WHERE value_date=_value_date
        AND office_id = @office_id;

        @notice             = 'EOD of ' + @office_code + ' for ' + CAST(@value_date AS varchar(24)) + ' completed without errors.';
        PRINT @notice;

        @notice             = 'OK';
        PRINT @notice;

        SELECT 1;
        RETURN;
    END;

    SELECT 0;
    RETURN;    
END;

--SELECT * FROM finance.perform_eod_operation(1, 1, 1, finance.get_value_date(1));


GO
