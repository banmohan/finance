IF OBJECT_ID('finance.get_periods') IS NOT NULL
DROP FUNCTION finance.get_periods;

GO

CREATE FUNCTION finance.get_periods
(
    @date_from                      date,
    @date_to                        date
)
RETURNS @period
TABLE
(
    period_name                             national character varying(500),
    date_from                               date,
    date_to                                 date
)
AS
BEGIN
    DECLARE @frequency_setups_temp TABLE
    (
        frequency_setup_id      int,
        value_date              date
    );

    INSERT INTO @frequency_setups_temp
    SELECT frequency_setup_id, value_date
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date BETWEEN @date_from AND @date_to
    AND finance.frequency_setups.deleted = 0
    ORDER BY value_date;

    INSERT INTO @period
    SELECT
        finance.get_frequency_setup_code_by_frequency_setup_id(frequency_setup_id),
        finance.get_frequency_setup_start_date_by_frequency_setup_id(frequency_setup_id),
        finance.get_frequency_setup_end_date_by_frequency_setup_id(frequency_setup_id)
    FROM @frequency_setups_temp;

    RETURN;
END;



GO
