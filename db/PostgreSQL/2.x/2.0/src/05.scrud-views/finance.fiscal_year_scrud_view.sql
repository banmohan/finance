DROP VIEW IF EXISTS finance.fiscal_year_scrud_view;

CREATE VIEW finance.fiscal_year_scrud_view
AS
SELECT
	finance.fiscal_year.fiscal_year_id,
	finance.fiscal_year.fiscal_year_code,
	finance.fiscal_year.fiscal_year_name,
	finance.fiscal_year.starts_from,
	finance.fiscal_year.ends_on,
	finance.fiscal_year.eod_required,
	core.get_office_name_by_office_id(finance.fiscal_year.office_id) AS office 
FROM finance.fiscal_year
WHERE NOT finance.fiscal_year.deleted;
