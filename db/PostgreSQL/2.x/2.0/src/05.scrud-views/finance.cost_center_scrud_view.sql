DROP VIEW IF EXISTS finance.cost_center_scrud_view;

CREATE VIEW finance.cost_center_scrud_view
AS
SELECT
    finance.cost_centers.cost_center_id,
    finance.cost_centers.cost_center_code,
    finance.cost_centers.cost_center_name
FROM finance.cost_centers
WHERE NOT finance.cost_centers.deleted;