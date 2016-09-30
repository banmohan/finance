DROP FUNCTION IF EXISTS finance.get_frequency_setup_end_date_by_frequency_setup_id(_frequency_setup_id integer);
CREATE FUNCTION finance.get_frequency_setup_end_date_by_frequency_setup_id(_frequency_setup_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN
        value_date
    FROM
        finance.frequency_setups
    WHERE
        frequency_setup_id = $1;
END
$$
LANGUAGE plpgsql;
