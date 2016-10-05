DROP FUNCTION IF EXISTS finance.get_verification_status_name_by_verification_status_id(_verification_status_id integer);

CREATE FUNCTION finance.get_verification_status_name_by_verification_status_id(_verification_status_id integer)
RETURNS text
AS
$$
BEGIN
    RETURN
        verification_status_name
    FROM finance.verification_statuses
    WHERE verification_status_id = _verification_status_id;
END
$$
LANGUAGE plpgsql;
