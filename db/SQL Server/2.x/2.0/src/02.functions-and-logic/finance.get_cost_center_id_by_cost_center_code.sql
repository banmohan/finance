IF OBJECT_ID('finance.get_cost_center_id_by_cost_center_code') IS NOT NULL
DROP FUNCTION finance.get_cost_center_id_by_cost_center_code;

GO

CREATE FUNCTION finance.get_cost_center_id_by_cost_center_code(@cost_center_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT cost_center_id
	    FROM finance.cost_centers
	    WHERE finance.cost_centers.cost_center_code=@cost_center_code
	    AND finance.cost_centers.deleted = 0
    );
END;


GO
