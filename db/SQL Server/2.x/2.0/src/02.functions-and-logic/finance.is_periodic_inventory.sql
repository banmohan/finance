IF OBJECT_ID('finance.is_periodic_inventory') IS NOT NULL
DROP FUNCTION finance.is_periodic_inventory;

GO

CREATE FUNCTION finance.is_periodic_inventory(@office_id integer)
RETURNS bit
AS
BEGIN
	--This is overriden by inventory module
    RETURN 0;
END;

GO
