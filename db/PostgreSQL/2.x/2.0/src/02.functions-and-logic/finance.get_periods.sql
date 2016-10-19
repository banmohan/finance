DROP FUNCTION IF EXISTS finance.get_periods
(
    _date_from                      date,
    _date_to                        date
);

CREATE FUNCTION finance.get_periods
(
    _date_from                      date,
    _date_to                        date
)
RETURNS finance.period[]
VOLATILE
AS
$$
BEGIN
    DROP TABLE IF EXISTS frequency_setups_temp;
    CREATE TEMPORARY TABLE frequency_setups_temp
    (
        frequency_setup_id      int,
        value_date              date
    ) ON COMMIT DROP;

    INSERT INTO frequency_setups_temp
    SELECT frequency_setup_id, value_date
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date BETWEEN _date_from AND _date_to
	AND NOT finance.frequency_setups.deleted
    ORDER BY value_date;

    RETURN
        array_agg
        (
            (
                finance.get_frequency_setup_code_by_frequency_setup_id(frequency_setup_id),
                finance.get_frequency_setup_start_date_by_frequency_setup_id(frequency_setup_id),
                finance.get_frequency_setup_end_date_by_frequency_setup_id(frequency_setup_id)
            )::finance.period
        )::finance.period[]
    FROM frequency_setups_temp;
END
$$
LANGUAGE plpgsql;