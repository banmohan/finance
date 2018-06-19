IF EXISTS (SELECT * FROM sys.indexes  WHERE name='fiscal_year_fiscal_year_name_uix' AND object_id = OBJECT_ID('finance.fiscal_year'))
DROP INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year;

GO

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year(office_id, fiscal_year_name)
WHERE deleted = 0;

GO

IF EXISTS (SELECT * FROM sys.indexes  WHERE name='fiscal_year_starts_from_uix' AND object_id = OBJECT_ID('finance.fiscal_year'))
DROP INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year;

GO

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year(office_id, starts_from)
WHERE deleted = 0;


IF EXISTS (SELECT * FROM sys.indexes  WHERE name='frequency_setups_frequency_setup_code_uix' AND object_id = OBJECT_ID('finance.frequency_setups'))
DROP INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups;

GO

CREATE UNIQUE INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups(office_id, frequency_setup_code)
WHERE deleted = 0;

