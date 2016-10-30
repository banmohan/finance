DROP FUNCTION IF EXISTS finance.get_frequency_end_date(_frequency_id integer, _value_date date);

CREATE FUNCTION finance.get_frequency_end_date(_frequency_id integer, _value_date date)
RETURNS date
STABLE
AS
$$
    DECLARE _end_date date;
BEGIN
    SELECT MIN(value_date)
    INTO _end_date
    FROM finance.frequency_setups
    WHERE value_date > $2
    AND frequency_id = ANY( finance.get_frequencies($1));

    RETURN _end_date;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM finance.get_frequency_end_date(1, '1-1-2000');