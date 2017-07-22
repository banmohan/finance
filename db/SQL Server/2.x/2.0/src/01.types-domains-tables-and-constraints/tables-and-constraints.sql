EXECUTE dbo.drop_schema 'finance';
GO
CREATE SCHEMA finance;
GO

CREATE TABLE finance.frequencies
(
    frequency_id                            integer PRIMARY KEY,
    frequency_code                          national character varying(12) NOT NULL,
    frequency_name                          national character varying(50) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);


CREATE UNIQUE INDEX frequencies_frequency_code_uix
ON finance.frequencies(frequency_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX frequencies_frequency_name_uix
ON finance.frequencies(frequency_name)
WHERE deleted = 0;

CREATE TABLE finance.cash_repositories
(
    cash_repository_id                      integer IDENTITY PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    cash_repository_code                    national character varying(12) NOT NULL,
    cash_repository_name                    national character varying(50) NOT NULL,
    parent_cash_repository_id               integer NULL REFERENCES finance.cash_repositories,
    description                             national character varying(100) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);


CREATE UNIQUE INDEX cash_repositories_cash_repository_code_uix
ON finance.cash_repositories(office_id, cash_repository_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX cash_repositories_cash_repository_name_uix
ON finance.cash_repositories(office_id, cash_repository_name)
WHERE deleted = 0;


CREATE TABLE finance.fiscal_year
(
	fiscal_year_id							int IDENTITY UNIQUE,
    fiscal_year_code                        national character varying(12) PRIMARY KEY,
    fiscal_year_name                        national character varying(50) NOT NULL,
    starts_from                             date NOT NULL,
    ends_on                                 date NOT NULL,
    eod_required                            bit NOT NULL DEFAULT(1),
    office_id                               integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year(fiscal_year_name)
WHERE deleted = 0;

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year(starts_from)
WHERE deleted = 0;

CREATE UNIQUE INDEX fiscal_year_ends_on_uix
ON finance.fiscal_year(ends_on)
WHERE deleted = 0;



CREATE TABLE finance.account_masters
(
    account_master_id                       smallint PRIMARY KEY,
    account_master_code                     national character varying(3) NOT NULL,
    account_master_name                     national character varying(40) NOT NULL,
    normally_debit                          bit NOT NULL CONSTRAINT account_masters_normally_debit_df DEFAULT(0),
    parent_account_master_id                smallint NULL REFERENCES finance.account_masters,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX account_master_code_uix
ON finance.account_masters(account_master_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX account_master_name_uix
ON finance.account_masters(account_master_name)
WHERE deleted = 0;

CREATE INDEX account_master_parent_account_master_id_inx
ON finance.account_masters(parent_account_master_id)
WHERE deleted = 0;



CREATE TABLE finance.cost_centers
(
    cost_center_id                          integer IDENTITY PRIMARY KEY,
    cost_center_code                        national character varying(24) NOT NULL,
    cost_center_name                        national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX cost_centers_cost_center_code_uix
ON finance.cost_centers(cost_center_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX cost_centers_cost_center_name_uix
ON finance.cost_centers(cost_center_name)
WHERE deleted = 0;


CREATE TABLE finance.frequency_setups
(
    frequency_setup_id                      integer IDENTITY PRIMARY KEY,
    fiscal_year_code                        national character varying(12) NOT NULL REFERENCES finance.fiscal_year(fiscal_year_code),
    frequency_setup_code                    national character varying(12) NOT NULL,
    value_date                              date NOT NULL UNIQUE,
    frequency_id                            integer NOT NULL REFERENCES finance.frequencies,
    office_id                                integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups(frequency_setup_code)
WHERE deleted = 0;



CREATE TABLE finance.accounts
(
    account_id                              integer IDENTITY PRIMARY KEY,
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters,
    account_number                          national character varying(24) NOT NULL,
    external_code                           national character varying(24) NULL CONSTRAINT accounts_external_code_df DEFAULT(''),
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    account_name                            national character varying(500) NOT NULL,
    description                             national character varying(1000) NULL,
    confidential                            bit NOT NULL CONSTRAINT accounts_confidential_df DEFAULT(0),
    is_transaction_node                     bit NOT NULL --Non transaction nodes cannot be used in transaction.
                                            CONSTRAINT accounts_is_transaction_node_df DEFAULT(1),
    sys_type                                bit NOT NULL CONSTRAINT accounts_sys_type_df DEFAULT(0),
    parent_account_id                       integer NULL REFERENCES finance.accounts,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);


CREATE UNIQUE INDEX accounts_account_number_uix
ON finance.accounts(account_number)
WHERE deleted = 0;

CREATE UNIQUE INDEX accounts_name_uix
ON finance.accounts(account_name)
WHERE deleted = 0;


CREATE TABLE finance.cash_flow_headings
(
    cash_flow_heading_id                    integer NOT NULL PRIMARY KEY,
    cash_flow_heading_code                  national character varying(12) NOT NULL,
    cash_flow_heading_name                  national character varying(100) NOT NULL,
    cash_flow_heading_type                  character(1) NOT NULL
                                            CONSTRAINT cash_flow_heading_cash_flow_heading_type_chk CHECK(cash_flow_heading_type IN('O', 'I', 'F')),
    is_debit                                bit NOT NULL CONSTRAINT cash_flow_headings_is_debit_df
                                            DEFAULT(0),
    is_sales                                bit NOT NULL CONSTRAINT cash_flow_headings_is_sales_df
                                            DEFAULT(0),
    is_purchase                             bit NOT NULL CONSTRAINT cash_flow_headings_is_purchase_df
                                            DEFAULT(0),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_code_uix
ON finance.cash_flow_headings(cash_flow_heading_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_name_uix
ON finance.cash_flow_headings(cash_flow_heading_code)
WHERE deleted = 0;

CREATE TABLE finance.bank_types
(
	bank_type_id							int IDENTITY PRIMARY KEY,
	bank_type_name							national character varying(1000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);


CREATE TABLE finance.bank_accounts
(
    bank_account_id                         int IDENTITY PRIMARY KEY,
	bank_account_name						national character varying(1000) NOT NULL,
    account_id                              integer REFERENCES finance.accounts,                                            
    maintained_by_user_id                   integer NOT NULL REFERENCES account.users,
	bank_type_id							integer NOT NULL REFERENCES finance.bank_types,
    is_merchant_account                     bit NOT NULL DEFAULT(0),
    office_id                               integer NOT NULL REFERENCES core.offices,
    bank_name                               national character varying(128) NOT NULL,
    bank_branch                             national character varying(128) NOT NULL,
    bank_contact_number                     national character varying(128) NULL,
    bank_account_number                     national character varying(128) NULL,
    bank_account_type                       national character varying(128) NULL,
    street                                  national character varying(50) NULL,
    city                                    national character varying(50) NULL,
    state                                   national character varying(50) NULL,
    country                                 national character varying(50) NULL,
    phone                                   national character varying(50) NULL,
    fax                                     national character varying(50) NULL,
    cell                                    national character varying(50) NULL,
    relationship_officer_name               national character varying(128) NULL,
    relationship_officer_contact_number     national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE TABLE finance.transaction_types
(
    transaction_type_id                     smallint PRIMARY KEY,
    transaction_type_code                   national character varying(4),
    transaction_type_name                   national character varying(100),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX transaction_types_transaction_type_code_uix
ON finance.transaction_types(transaction_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX transaction_types_transaction_type_name_uix
ON finance.transaction_types(transaction_type_name)
WHERE deleted = 0;

INSERT INTO finance.transaction_types(transaction_type_id, transaction_type_code, transaction_type_name)
SELECT 1, 'Any', 'Any (Debit or Credit)' UNION ALL
SELECT 2, 'Dr', 'Debit' UNION ALL
SELECT 3, 'Cr', 'Credit';



CREATE TABLE finance.cash_flow_setup
(
    cash_flow_setup_id                      integer IDENTITY PRIMARY KEY,
    cash_flow_heading_id                    integer NOT NULL REFERENCES finance.cash_flow_headings,
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE INDEX cash_flow_setup_cash_flow_heading_id_inx
ON finance.cash_flow_setup(cash_flow_heading_id)
WHERE deleted = 0;

CREATE INDEX cash_flow_setup_account_master_id_inx
ON finance.cash_flow_setup(account_master_id)
WHERE deleted = 0;



CREATE TABLE finance.transaction_master
(
    transaction_master_id                   bigint IDENTITY PRIMARY KEY,
    transaction_counter                     integer NOT NULL, --Sequence of transactions of a date
    transaction_code                        national character varying(50) NOT NULL,
    book                                    national character varying(50) NOT NULL, --Transaction book. Ex. Sales, Purchase, Journal
    value_date                              date NOT NULL,
    book_date                                  date NOT NULL,
    transaction_ts                          DATETIMEOFFSET NOT NULL   
                                            DEFAULT(GETUTCDATE()),
    login_id                                bigint NOT NULL REFERENCES account.logins,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    cost_center_id                          integer REFERENCES finance.cost_centers,
    reference_number                        national character varying(24),
    statement_reference                     national character varying(2000),
    last_verified_on                        DATETIMEOFFSET, 
    verified_by_user_id                     integer REFERENCES account.users,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses   
                                            DEFAULT(0/*Awaiting verification*/),
    verification_reason                     national character varying(128) NOT NULL DEFAULT(''),
    cascading_tran_id                         bigint REFERENCES finance.transaction_master,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX transaction_master_transaction_code_uix
ON finance.transaction_master(transaction_code)
WHERE deleted = 0;

CREATE INDEX transaction_master_cascading_tran_id_inx
ON finance.transaction_master(cascading_tran_id)
WHERE deleted = 0;

CREATE INDEX transaction_master_value_date_inx
ON finance.transaction_master(value_date)
WHERE deleted = 0;

CREATE INDEX transaction_master_book_date_inx
ON finance.transaction_master(book_date)
WHERE deleted = 0;

CREATE TABLE finance.transaction_documents
(
    document_id                             bigint IDENTITY PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    original_file_name                      national character varying(500) NOT NULL,
    file_extension                          national character varying(50),
    file_path                               national character varying(2000) NOT NULL,
    memo                                    national character varying(2000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);


CREATE TABLE finance.transaction_details
(
    transaction_detail_id                   bigint IDENTITY PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    value_date                              date NOT NULL,
    book_date                               date NOT NULL,
    tran_type                               national character varying(4) NOT NULL CHECK(tran_type IN ('Dr', 'Cr')),
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    statement_reference                     national character varying(2000),
    reconciliation_memo                     national character varying(2000),
    cash_repository_id                      integer REFERENCES finance.cash_repositories,
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    amount_in_currency                      numeric(30, 6) NOT NULL,
    local_currency_code                     national character varying(12) NOT NULL REFERENCES core.currencies,
    er                                      numeric(30, 6) NOT NULL,
    amount_in_local_currency                numeric(30, 6) NOT NULL,  
    office_id                               integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE())
);

CREATE NONCLUSTERED INDEX transaction_details_account_id_inx
ON finance.transaction_details(account_id)
INCLUDE (transaction_master_id,tran_type,amount_in_local_currency);


CREATE NONCLUSTERED INDEX transaction_details_value_date_inx
ON finance.transaction_details(value_date)
INCLUDE (transaction_master_id,tran_type,amount_in_local_currency);

CREATE NONCLUSTERED INDEX transaction_details_book_date_inx
ON finance.transaction_details(book_date)
INCLUDE (transaction_master_id,tran_type,amount_in_local_currency);

CREATE NONCLUSTERED INDEX transaction_details_office_id_inx
ON finance.transaction_details(office_id)
INCLUDE (transaction_master_id,tran_type,amount_in_local_currency);

CREATE NONCLUSTERED INDEX transaction_details_cash_repository_id_inx
ON finance.transaction_details(cash_repository_id)
INCLUDE (transaction_master_id,tran_type,amount_in_local_currency);

CREATE NONCLUSTERED INDEX transaction_details_tran_type_inx
ON finance.transaction_details(tran_type)
INCLUDE (transaction_master_id,amount_in_local_currency);


CREATE TABLE finance.card_types
(
    card_type_id                            integer PRIMARY KEY,
    card_type_code                          national character varying(12) NOT NULL,
    card_type_name                          national character varying(100) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)
);

CREATE UNIQUE INDEX card_types_card_type_code_uix
ON finance.card_types(card_type_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX card_types_card_type_name_uix
ON finance.card_types(card_type_name)
WHERE deleted = 0;

CREATE TABLE finance.payment_cards
(
    payment_card_id                         int IDENTITY PRIMARY KEY,
    payment_card_code                       national character varying(12) NOT NULL,
    payment_card_name                       national character varying(100) NOT NULL,
    card_type_id                            integer NOT NULL REFERENCES finance.card_types,            
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)            
);

CREATE UNIQUE INDEX payment_cards_payment_card_code_uix
ON finance.payment_cards(payment_card_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX payment_cards_payment_card_name_uix
ON finance.payment_cards(payment_card_name)
WHERE deleted = 0;    


CREATE TABLE finance.merchant_fee_setup
(
    merchant_fee_setup_id                   int IDENTITY PRIMARY KEY,
    merchant_account_id                     integer NOT NULL REFERENCES finance.bank_accounts,
    payment_card_id                         integer NOT NULL REFERENCES finance.payment_cards,
    rate                                    numeric(30, 6) NOT NULL,
    customer_pays_fee                       bit NOT NULL DEFAULT(0),
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    statement_reference                     national character varying(2000) NOT NULL DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                 bit DEFAULT(0)            
);

CREATE UNIQUE INDEX merchant_fee_setup_merchant_account_id_payment_card_id_uix
ON finance.merchant_fee_setup(merchant_account_id, payment_card_id)
WHERE deleted = 0;


CREATE TABLE finance.exchange_rates
(
    exchange_rate_id                        bigint IDENTITY PRIMARY KEY,
    updated_on                              DATETIMEOFFSET NOT NULL   
                                            CONSTRAINT exchange_rates_updated_on_df 
                                            DEFAULT(GETUTCDATE()),
    office_id                               integer NOT NULL REFERENCES core.offices,
    status                                  bit NOT NULL   
                                            CONSTRAINT exchange_rates_status_df 
                                            DEFAULT(1)
);

CREATE TABLE finance.exchange_rate_details
(
    exchange_rate_detail_id                 bigint IDENTITY PRIMARY KEY,
    exchange_rate_id                        bigint NOT NULL REFERENCES finance.exchange_rates,
    local_currency_code                     national character varying(12) NOT NULL REFERENCES core.currencies,
    foreign_currency_code                   national character varying(12) NOT NULL REFERENCES core.currencies,
    unit                                    integer NOT NULL,
    exchange_rate                           numeric(30, 6) NOT NULL
);


CREATE TYPE finance.period AS
TABLE
(
    period_name                             national character varying(500),
    date_from                               date,
    date_to                                 date
);

CREATE TABLE finance.journal_verification_policy
(
    journal_verification_policy_id          integer IDENTITY PRIMARY KEY,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    can_verify                              bit NOT NULL DEFAULT(0),
    verification_limit                      numeric(30, 6) NOT NULL DEFAULT(0),
    can_self_verify                         bit NOT NULL DEFAULT(0),
    self_verification_limit                 numeric(30, 6) NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               bit NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)            
);


CREATE TABLE finance.auto_verification_policy
(
    auto_verification_policy_id             integer IDENTITY PRIMARY KEY,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    verification_limit                      numeric(30, 6) NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               bit NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)                                            
);

CREATE TABLE finance.tax_setups
(
    tax_setup_id                            int IDENTITY PRIMARY KEY,
    office_id                                integer NOT NULL REFERENCES core.offices,
    income_tax_rate                            numeric(30, 6) NOT NULL,
    income_tax_account_id                    integer NOT NULL REFERENCES finance.accounts,
    sales_tax_rate                            numeric(30, 6) NOT NULL,
    sales_tax_account_id                    integer NOT NULL REFERENCES finance.accounts,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETUTCDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX tax_setup_office_id_uix
ON finance.tax_setups(office_id)
WHERE deleted = 0;


CREATE TABLE finance.routines
(
    routine_id                              integer IDENTITY NOT NULL PRIMARY KEY,
    "order"                                 integer NOT NULL,
    routine_code                            national character varying(48) NOT NULL,
    routine_name                            national character varying(128) NOT NULL UNIQUE,
    status                                  bit NOT NULL CONSTRAINT routines_status_df DEFAULT(1)
);

CREATE UNIQUE INDEX routines_routine_code_uix
ON finance.routines(routine_code);

CREATE TABLE finance.day_operation
(
    day_id                                  bigint IDENTITY PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    value_date                              date NOT NULL,
    started_on                              DATETIMEOFFSET NOT NULL,
    started_by                              integer NOT NULL REFERENCES account.users,    
    completed_on                            DATETIMEOFFSET NULL,
    completed_by                            integer NULL REFERENCES account.users,
    completed                               bit NOT NULL 
                                            CONSTRAINT day_operation_completed_df DEFAULT(0),
                                            CONSTRAINT day_operation_completed_chk 
                                            CHECK
                                            (
                                                (completed = 1 OR completed_on IS NOT NULL)
                                                OR
                                                (completed = 0 OR completed_on IS NULL)
                                            )
);


CREATE UNIQUE INDEX day_operation_value_date_uix
ON finance.day_operation(value_date);

CREATE INDEX day_operation_completed_on_inx
ON finance.day_operation(completed_on);

CREATE TABLE finance.day_operation_routines
(
    day_operation_routine_id                bigint IDENTITY NOT NULL PRIMARY KEY,
    day_id                                  bigint NOT NULL REFERENCES finance.day_operation,
    routine_id                              integer NOT NULL REFERENCES finance.routines,
    started_on                              DATETIMEOFFSET NOT NULL,
    completed_on                            DATETIMEOFFSET NULL
);

CREATE INDEX day_operation_routines_started_on_inx
ON finance.day_operation_routines(started_on);

CREATE INDEX day_operation_routines_completed_on_inx
ON finance.day_operation_routines(completed_on);



GO
