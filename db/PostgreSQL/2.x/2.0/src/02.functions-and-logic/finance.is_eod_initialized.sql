DROP FUNCTION IF EXISTS finance.is_eod_initialized(_office_id integer, _value_date date);

CREATE FUNCTION finance.is_eod_initialized(_office_id integer, _value_date date)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS
    (
        SELECT * FROM finance.day_operation
        WHERE office_id = _office_id
        AND value_date = _value_date
        AND completed = false
    ) then
        RETURN true;
    END IF;

    RETURN false;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM finance.is_eod_initialized(1, '1-1-2000');