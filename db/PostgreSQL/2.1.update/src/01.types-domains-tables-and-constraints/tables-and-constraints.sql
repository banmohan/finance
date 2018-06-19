DROP INDEX IF EXISTS finance.fiscal_year_fiscal_year_name_uix;

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year(office_id, fiscal_year_name)
WHERE NOT deleted;


DROP INDEX IF EXISTS finance.fiscal_year_starts_from_uix;

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year(office_id, starts_from)
WHERE NOT deleted;

DROP INDEX IF EXISTS finance.frequency_setups_frequency_setup_code_uix;

CREATE UNIQUE INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups(office_id, UPPER(frequency_setup_code))
WHERE NOT deleted;

DROP INDEX IF EXISTS finance.day_operation_value_date_uix;

CREATE UNIQUE INDEX day_operation_value_date_uix
ON finance.day_operation(office_id, value_date);
