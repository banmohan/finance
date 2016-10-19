DROP FUNCTION IF EXISTS finance.get_cost_center_id_by_cost_center_code(text);

CREATE FUNCTION finance.get_cost_center_id_by_cost_center_code(text)
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN cost_center_id
    FROM finance.cost_centers
    WHERE finance.cost_centers.cost_center_code=$1
	AND NOT finance.cost_centers.deleted;
END
$$
LANGUAGE plpgsql;