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
        finance.frequency_setups.frequency_setup_id = $1
	AND NOT finance.frequency_setups.deleted;
END
$$
LANGUAGE plpgsql;
