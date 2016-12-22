IF OBJECT_ID('finance.get_value_date') IS NOT NULL
DROP FUNCTION finance.get_value_date;

GO

CREATE FUNCTION finance.get_value_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @day_id                         bigint;
    DECLARE @completed                      bit;
    DECLARE @value_date                     date;
    DECLARE @day_operation_value_date       date;

    SELECT
        @day_id                     = finance.day_operation.day_id,
        @completed                  = finance.day_operation.completed,
        @day_operation_value_date   = finance.day_operation.value_date  
    FROM finance.day_operation
    WHERE office_id = @office_id
    AND value_date =
    (
        SELECT MAX(value_date)
        FROM finance.day_operation
        WHERE office_id = @office_id
    );

    IF(@day_id IS NOT NULL)
    BEGIN
        IF(@completed = 1)
        BEGIN
            SET @value_date  = DATEADD(day, 1, @day_operation_value_date);
        END
        ELSE
        BEGIN
            SET @value_date  = @day_operation_value_date;    
        END;
    END;

    IF(@value_date IS NULL)
    BEGIN
        --SET @value_date = GETUTCDATE() AT time zone config.get_server_timezone();
        --Todo: validate the date and time produced by the following function
        SET @value_date = CAST(SYSDATETIMEOFFSET() AS date);
    END;
    
    RETURN @value_date;
END;

GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

CREATE FUNCTION finance.get_month_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    );
END;

GO

IF OBJECT_ID('finance.get_month_start_date') IS NOT NULL
DROP FUNCTION finance.get_month_start_date;

GO

CREATE FUNCTION finance.get_month_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    );

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from 
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_quarter_end_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_end_date;

GO

CREATE FUNCTION finance.get_quarter_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 2
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_quarter_start_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date;

GO

CREATE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    )
    AND frequency_id > 2;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;

GO

IF OBJECT_ID('finance.get_fiscal_half_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_end_date;

GO

CREATE FUNCTION finance.get_fiscal_half_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 3
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_fiscal_half_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_start_date;

GO

CREATE FUNCTION finance.get_fiscal_half_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date)) 
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    )
    AND frequency_id > 3;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_fiscal_year_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_end_date;

GO

CREATE FUNCTION finance.get_fiscal_year_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 4
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_fiscal_year_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_start_date;

GO

CREATE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = starts_from
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.office_id = @office_id;

    RETURN @date;
END;




--SELECT 1 AS office_id, finance.get_value_date(1) AS today, finance.get_month_start_date(1) AS month_start_date,finance.get_month_end_date(1) AS month_end_date, finance.get_quarter_start_date(1) AS quarter_start_date, finance.get_quarter_end_date(1) AS quarter_end_date, finance.get_fiscal_half_start_date(1) AS fiscal_half_start_date, finance.get_fiscal_half_end_date(1) AS fiscal_half_end_date, finance.get_fiscal_year_start_date(1) AS fiscal_year_start_date, finance.get_fiscal_year_end_date(1) AS fiscal_year_end_date;

GO
