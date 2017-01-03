IF OBJECT_ID('finance.fiscal_year_scrud_view') IS NOT NULL
DROP VIEW finance.fiscal_year_scrud_view;

GO

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
WHERE finance.fiscal_year.deleted = 0;

GO
