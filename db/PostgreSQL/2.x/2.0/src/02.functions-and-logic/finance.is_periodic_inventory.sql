DROP FUNCTION IF EXISTS finance.is_periodic_inventory(_office_id integer);

CREATE FUNCTION finance.is_periodic_inventory(_office_id integer)
RETURNS boolean
AS
$$
BEGIN
	--This is overriden by inventory module
    RETURN false;
END
$$
LANGUAGE plpgsql;

