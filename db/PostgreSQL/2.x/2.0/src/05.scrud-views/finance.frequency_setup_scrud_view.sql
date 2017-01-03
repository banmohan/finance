DROP VIEW IF EXISTS finance.frequency_setup_scrud_view;

CREATE VIEW finance.frequency_setup_scrud_view
AS
SELECT
	finance.frequency_setups.frequency_setup_id,
	finance.frequency_setups.fiscal_year_code,
	finance.frequency_setups.frequency_setup_code,
	finance.frequency_setups.value_date,
	finance.frequencies.frequency_code,
	core.get_office_name_by_office_id(finance.frequency_setups.office_id) AS office
FROM finance.frequency_setups
INNER JOIN finance.frequencies
ON finance.frequencies.frequency_id = finance.frequency_setups.frequency_id
WHERE NOT finance.frequency_setups.deleted;

