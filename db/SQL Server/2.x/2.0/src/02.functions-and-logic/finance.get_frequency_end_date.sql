IF OBJECT_ID('finance.get_frequency_end_date') IS NOT NULL
DROP FUNCTION finance.get_frequency_end_date;

GO

CREATE FUNCTION finance.get_frequency_end_date(@frequency_id integer, @value_date date)
RETURNS date
AS
BEGIN
    DECLARE @end_date date;

    SELECT @end_date = MIN(value_date)
    FROM finance.frequency_setups
    WHERE value_date > @value_date
    AND frequency_id IN(SELECT finance.get_frequencies(@frequency_id));

    RETURN @end_date;
END;



--SELECT * FROM finance.get_frequency_end_date(1, '1-1-2000');

GO
