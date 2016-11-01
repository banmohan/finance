DROP VIEW IF EXISTS finance.frequency_date_view;

CREATE VIEW finance.frequency_date_view
AS
SELECT 
    office_id AS office_id, 
    finance.get_value_date(office_id) AS today, 
    finance.is_new_day_started(office_id) as new_day_started,
    finance.get_month_start_date(office_id) AS month_start_date,
    finance.get_month_end_date(office_id) AS month_end_date, 
    finance.get_quarter_start_date(office_id) AS quarter_start_date, 
    finance.get_quarter_end_date(office_id) AS quarter_end_date, 
    finance.get_fiscal_half_start_date(office_id) AS fiscal_half_start_date, 
    finance.get_fiscal_half_end_date(office_id) AS fiscal_half_end_date, 
    finance.get_fiscal_year_start_date(office_id) AS fiscal_year_start_date, 
    finance.get_fiscal_year_end_date(office_id) AS fiscal_year_end_date 
FROM core.offices;
