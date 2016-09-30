DROP FUNCTION IF EXISTS finance.get_frequency_setup_start_date_frequency_setup_id(_frequency_setup_id integer);
CREATE FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id(_frequency_setup_id integer)
RETURNS date
AS
$$
    DECLARE _start_date date;
BEGIN
    SELECT MAX(value_date) + 1 
    INTO _start_date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT value_date
        FROM finance.frequency_setups
        WHERE frequency_setup_id = $1
    );

    IF(_start_date IS NULL) THEN
        SELECT starts_from 
        INTO _start_date
        FROM finance.fiscal_year;
    END IF;

    RETURN _start_date;
END
$$
LANGUAGE plpgsql;