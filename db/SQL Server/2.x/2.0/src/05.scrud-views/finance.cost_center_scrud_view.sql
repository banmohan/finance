IF OBJECT_ID('finance.cost_center_scrud_view') IS NOT NULL
DROP VIEW finance.cost_center_scrud_view;

GO



CREATE VIEW finance.cost_center_scrud_view
AS
SELECT
    finance.cost_centers.cost_center_id,
    finance.cost_centers.cost_center_code,
    finance.cost_centers.cost_center_name
FROM finance.cost_centers
WHERE finance.cost_centers.deleted = 0;

GO
