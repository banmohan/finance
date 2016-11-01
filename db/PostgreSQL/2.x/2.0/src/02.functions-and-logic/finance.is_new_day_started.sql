DROP FUNCTION IF EXISTS finance.is_new_day_started(_office_id integer);

CREATE or replace FUNCTION finance.is_new_day_started(_office_id integer)
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS
    (
        SELECT 0 FROM finance.day_operation
        WHERE finance.day_operation.office_id = _office_id
        AND finance.day_operation.completed = false
        LIMIT 1
    ) THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$
LANGUAGE plpgsql;


--SELECT * FROM finance.is_new_day_started(1);