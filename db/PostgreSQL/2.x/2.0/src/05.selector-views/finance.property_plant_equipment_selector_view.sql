DROP VIEW IF EXISTS finance.property_plant_equipment_selector_view;

CREATE VIEW finance.property_plant_equipment_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS property_plant_equipment_id,
    finance.account_scrud_view.account_name AS property_plant_equipment_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10201))
ORDER BY account_id;

