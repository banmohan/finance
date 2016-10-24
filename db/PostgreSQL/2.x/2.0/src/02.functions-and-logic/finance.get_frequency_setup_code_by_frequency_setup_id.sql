DROP FUNCTION IF EXISTS finance.get_frequency_setup_code_by_frequency_setup_id(_frequency_setup_id integer);

CREATE FUNCTION finance.get_frequency_setup_code_by_frequency_setup_id(_frequency_setup_id integer)
RETURNS text
STABLE
AS
$$
BEGIN
    RETURN frequency_setup_code
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.frequency_setup_id = $1
	AND NOT finance.frequency_setups.deleted;
END
$$
LANGUAGE plpgsql;
