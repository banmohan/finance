DROP FUNCTION IF EXISTS finance.is_restricted_mode();

CREATE FUNCTION finance.is_restricted_mode()
RETURNS boolean
AS
$$
BEGIN
    IF EXISTS
    (
        SELECT 0 FROM finance.day_operation
        WHERE completed = false
        LIMIT 1
    ) THEN
        RETURN true;
    END IF;

    RETURN false;
END;
$$
LANGUAGE plpgsql;