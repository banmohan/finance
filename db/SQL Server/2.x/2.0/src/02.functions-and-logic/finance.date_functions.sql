IF OBJECT_ID('finance.get_date') IS NOT NULL
DROP FUNCTION finance.get_date;
GO

CREATE FUNCTION finance.get_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN finance.get_value_date(@office_id);
END;


GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

CREATE FUNCTION finance.get_month_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND finance.frequency_setups.deleted = 0;
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

    SELECT MAX(value_date) + 1
    INTO @date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT starts_from 
        INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 2
    AND finance.frequency_setups.deleted = 0;
END;




GO

IF OBJECT_ID('finance.get_quarter_start_date(@office_id') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date(@office_id;

GO

CREATE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT MAX(value_date) + 1
    INTO @date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND frequency_id > 2
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT starts_from 
        INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 3
    AND finance.frequency_setups.deleted = 0;
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

    SELECT MAX(value_date) + 1
    INTO @date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND frequency_id > 3
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT starts_from 
        INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 4
    AND finance.frequency_setups.deleted = 0;
END;



GO

IF OBJECT_ID('') IS NOT NULL
DROP FUNCTION;

GO

CREATE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT starts_from 
    INTO @date
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.deleted = 0;

    RETURN @date;
END;




GO
