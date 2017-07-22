DROP SCHEMA IF EXISTS finance CASCADE;
CREATE SCHEMA finance;

CREATE TABLE finance.frequencies
(
    frequency_id                            SERIAL PRIMARY KEY,
    frequency_code                          national character varying(12) NOT NULL,
    frequency_name                          national character varying(50) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE UNIQUE INDEX frequencies_frequency_code_uix
ON finance.frequencies(UPPER(frequency_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX frequencies_frequency_name_uix
ON finance.frequencies(UPPER(frequency_name))
WHERE NOT deleted;

CREATE TABLE finance.cash_repositories
(
    cash_repository_id                      SERIAL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    cash_repository_code                    national character varying(12) NOT NULL,
    cash_repository_name                    national character varying(50) NOT NULL,
    parent_cash_repository_id               integer NULL REFERENCES finance.cash_repositories,
    description                             national character varying(100) NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE UNIQUE INDEX cash_repositories_cash_repository_code_uix
ON finance.cash_repositories(office_id, UPPER(cash_repository_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX cash_repositories_cash_repository_name_uix
ON finance.cash_repositories(office_id, UPPER(cash_repository_name))
WHERE NOT deleted;


CREATE TABLE finance.fiscal_year
(
	fiscal_year_id							SERIAL NOT NULL UNIQUE,
    fiscal_year_code                        national character varying(12) PRIMARY KEY,
    fiscal_year_name                        national character varying(50) NOT NULL,
    starts_from                             date NOT NULL,
    ends_on                                 date NOT NULL,
	eod_required							boolean NOT NULL DEFAULT(true),
	office_id								integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year(UPPER(fiscal_year_name))
WHERE NOT deleted;

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year(starts_from)
WHERE NOT deleted;

CREATE UNIQUE INDEX fiscal_year_ends_on_uix
ON finance.fiscal_year(ends_on)
WHERE NOT deleted;



CREATE TABLE finance.account_masters
(
    account_master_id                       smallint PRIMARY KEY,
    account_master_code                     national character varying(3) NOT NULL,
    account_master_name                     national character varying(40) NOT NULL,
    normally_debit                          boolean NOT NULL CONSTRAINT account_masters_normally_debit_df DEFAULT(false),
    parent_account_master_id                smallint NULL REFERENCES finance.account_masters,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX account_master_code_uix
ON finance.account_masters(UPPER(account_master_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX account_master_name_uix
ON finance.account_masters(UPPER(account_master_name))
WHERE NOT deleted;

CREATE INDEX account_master_parent_account_master_id_inx
ON finance.account_masters(parent_account_master_id)
WHERE NOT deleted;



CREATE TABLE finance.cost_centers
(
    cost_center_id                          SERIAL PRIMARY KEY,
    cost_center_code                        national character varying(24) NOT NULL,
    cost_center_name                        national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX cost_centers_cost_center_code_uix
ON finance.cost_centers(UPPER(cost_center_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX cost_centers_cost_center_name_uix
ON finance.cost_centers(UPPER(cost_center_name))
WHERE NOT deleted;


CREATE TABLE finance.frequency_setups
(
    frequency_setup_id                      SERIAL PRIMARY KEY,
    fiscal_year_code                        national character varying(12) NOT NULL REFERENCES finance.fiscal_year(fiscal_year_code),
    frequency_setup_code                    national character varying(12) NOT NULL,
    value_date                              date NOT NULL UNIQUE,
    frequency_id                            integer NOT NULL REFERENCES finance.frequencies,
	office_id								integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups(UPPER(frequency_setup_code))
WHERE NOT deleted;



CREATE TABLE finance.accounts
(
    account_id                              SERIAL PRIMARY KEY,
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters,
    account_number                          national character varying(24) NOT NULL,
    external_code                           national character varying(24) NULL CONSTRAINT accounts_external_code_df DEFAULT(''),
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    account_name                            national character varying(500) NOT NULL,
    description                             national character varying(1000) NULL,
    confidential                            boolean NOT NULL CONSTRAINT accounts_confidential_df DEFAULT(false),
    is_transaction_node                     boolean NOT NULL --Non transaction nodes cannot be used in transaction.
                                            CONSTRAINT accounts_is_transaction_node_df DEFAULT(true),
    sys_type                                boolean NOT NULL CONSTRAINT accounts_sys_type_df DEFAULT(false),
    parent_account_id                       integer NULL REFERENCES finance.accounts,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE UNIQUE INDEX accounts_account_number_uix
ON finance.accounts(UPPER(account_number))
WHERE NOT deleted;

CREATE UNIQUE INDEX accounts_name_uix
ON finance.accounts(UPPER(account_name))
WHERE NOT deleted;


CREATE TABLE finance.cash_flow_headings
(
    cash_flow_heading_id                    integer NOT NULL PRIMARY KEY,
    cash_flow_heading_code                  national character varying(12) NOT NULL,
    cash_flow_heading_name                  national character varying(100) NOT NULL,
    cash_flow_heading_type                  character(1) NOT NULL
                                            CONSTRAINT cash_flow_heading_cash_flow_heading_type_chk CHECK(cash_flow_heading_type IN('O', 'I', 'F')),
    is_debit                                boolean NOT NULL CONSTRAINT cash_flow_headings_is_debit_df
                                            DEFAULT(false),
    is_sales                                boolean NOT NULL CONSTRAINT cash_flow_headings_is_sales_df
                                            DEFAULT(false),
    is_purchase                             boolean NOT NULL CONSTRAINT cash_flow_headings_is_purchase_df
                                            DEFAULT(false),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_code_uix
ON finance.cash_flow_headings(UPPER(cash_flow_heading_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_name_uix
ON finance.cash_flow_headings(UPPER(cash_flow_heading_code))
WHERE NOT deleted;


CREATE TABLE finance.bank_types
(
	bank_type_id							SERIAL PRIMARY KEY,
	bank_type_name							national character varying(1000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE TABLE finance.bank_accounts
(
	bank_account_id							SERIAL PRIMARY KEY,
	bank_account_name						national character varying(1000) NOT NULL,
    account_id                              integer REFERENCES finance.accounts,                                            
    maintained_by_user_id                   integer NOT NULL REFERENCES account.users,
	bank_type_id							integer NOT NULL REFERENCES finance.bank_types,
	is_merchant_account 					boolean NOT NULL DEFAULT(false),
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
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE TABLE finance.transaction_types
(
    transaction_type_id                     smallint PRIMARY KEY,
    transaction_type_code                   national character varying(4),
    transaction_type_name                   national character varying(100),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX transaction_types_transaction_type_code_uix
ON finance.transaction_types(UPPER(transaction_type_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX transaction_types_transaction_type_name_uix
ON finance.transaction_types(UPPER(transaction_type_name))
WHERE NOT deleted;

INSERT INTO finance.transaction_types
SELECT 1, 'Any', 'Any (Debit or Credit)' UNION ALL
SELECT 2, 'Dr', 'Debit' UNION ALL
SELECT 3, 'Cr', 'Credit';



CREATE TABLE finance.cash_flow_setup
(
    cash_flow_setup_id                      SERIAL PRIMARY KEY,
    cash_flow_heading_id                    integer NOT NULL REFERENCES finance.cash_flow_headings,
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE INDEX cash_flow_setup_cash_flow_heading_id_inx
ON finance.cash_flow_setup(cash_flow_heading_id)
WHERE NOT deleted;

CREATE INDEX cash_flow_setup_account_master_id_inx
ON finance.cash_flow_setup(account_master_id)
WHERE NOT deleted;



CREATE TABLE finance.transaction_master
(
    transaction_master_id                   BIGSERIAL PRIMARY KEY,
    transaction_counter                     integer NOT NULL, --Sequence of transactions of a date
    transaction_code                        national character varying(50) NOT NULL,
    book                                    national character varying(50) NOT NULL, --Transaction book. Ex. Sales, Purchase, Journal
    value_date                              date NOT NULL,
    book_date                              	date NOT NULL,
    transaction_ts                          TIMESTAMP WITH TIME ZONE NOT NULL   
                                            DEFAULT(NOW()),
    login_id                                bigint NOT NULL REFERENCES account.logins,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    cost_center_id                          integer REFERENCES finance.cost_centers,
    reference_number                        national character varying(24),
    statement_reference                     text,
    last_verified_on                        TIMESTAMP WITH TIME ZONE, 
    verified_by_user_id                     integer REFERENCES account.users,
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses   
                                            DEFAULT(0/*Awaiting verification*/),
    verification_reason                     national character varying(128) NOT NULL DEFAULT(''),
	cascading_tran_id 						bigint REFERENCES finance.transaction_master,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX transaction_master_transaction_code_uix
ON finance.transaction_master(UPPER(transaction_code))
WHERE NOT deleted;

CREATE INDEX transaction_master_cascading_tran_id_inx
ON finance.transaction_master(cascading_tran_id)
WHERE NOT deleted;

CREATE INDEX transaction_master_value_date_inx
ON finance.transaction_master(value_date)
WHERE NOT deleted;

CREATE INDEX transaction_master_book_date_inx
ON finance.transaction_master(book_date)
WHERE NOT deleted;

CREATE TABLE finance.transaction_documents
(
	document_id								BIGSERIAL PRIMARY KEY,
	transaction_master_id					bigint NOT NULL REFERENCES finance.transaction_master,
	original_file_name						national character varying(500) NOT NULL,
	file_extension							national character varying(50),
	file_path								national character varying(2000) NOT NULL,
	memo									national character varying(2000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);


CREATE TABLE finance.transaction_details
(
    transaction_detail_id                   BIGSERIAL PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    value_date                              date NOT NULL,
    book_date                              	date NOT NULL,
    tran_type                               national character varying(4) NOT NULL CHECK(tran_type IN ('Dr', 'Cr')),
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    statement_reference                     text,
	reconciliation_memo						text,
    cash_repository_id                      integer REFERENCES finance.cash_repositories,
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    amount_in_currency                      money_strict NOT NULL,
    local_currency_code                     national character varying(12) NOT NULL REFERENCES core.currencies,
    er                                      decimal_strict NOT NULL,
    amount_in_local_currency                money_strict NOT NULL,  
    office_id                               integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW())
);

CREATE INDEX transaction_details_account_id_inx
ON finance.transaction_details(account_id);

CREATE INDEX transaction_details_value_date_inx
ON finance.transaction_details(value_date);

CREATE INDEX transaction_details_book_date_inx
ON finance.transaction_details(book_date);

CREATE INDEX transaction_details_office_id_inx
ON finance.transaction_details(office_id);

CREATE INDEX transaction_details_cash_repository_id_inx
ON finance.transaction_details(cash_repository_id);

CREATE INDEX transaction_details_tran_type_inx
ON finance.transaction_details(tran_type);


CREATE TABLE finance.card_types
(
	card_type_id                    		integer PRIMARY KEY,
	card_type_code                  		national character varying(12) NOT NULL,
	card_type_name                  		national character varying(100) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX card_types_card_type_code_uix
ON finance.card_types(UPPER(card_type_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX card_types_card_type_name_uix
ON finance.card_types(UPPER(card_type_name))
WHERE NOT deleted;

CREATE TABLE finance.payment_cards
(
	payment_card_id                     	SERIAL PRIMARY KEY,
	payment_card_code                   	national character varying(12) NOT NULL,
	payment_card_name                   	national character varying(100) NOT NULL,
	card_type_id                        	integer NOT NULL REFERENCES finance.card_types,            
	audit_user_id                       	integer NULL REFERENCES account.users,            
	audit_ts                                TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)            
);

CREATE UNIQUE INDEX payment_cards_payment_card_code_uix
ON finance.payment_cards(UPPER(payment_card_code))
WHERE NOT deleted;

CREATE UNIQUE INDEX payment_cards_payment_card_name_uix
ON finance.payment_cards(UPPER(payment_card_name))
WHERE NOT deleted;    


CREATE TABLE finance.merchant_fee_setup
(
	merchant_fee_setup_id               	SERIAL PRIMARY KEY,
	merchant_account_id                 	integer NOT NULL REFERENCES finance.bank_accounts,
	payment_card_id                     	integer NOT NULL REFERENCES finance.payment_cards,
	rate                                	public.decimal_strict NOT NULL,
	customer_pays_fee                   	boolean NOT NULL DEFAULT(false),
	account_id                          	integer NOT NULL REFERENCES finance.accounts,
	statement_reference                 	national character varying(128) NOT NULL DEFAULT(''),
	audit_user_id                       	integer NULL REFERENCES account.users,            
	audit_ts                            	TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)            
);

CREATE UNIQUE INDEX merchant_fee_setup_merchant_account_id_payment_card_id_uix
ON finance.merchant_fee_setup(merchant_account_id, payment_card_id)
WHERE NOT deleted;


CREATE TABLE finance.exchange_rates
(
    exchange_rate_id                        BIGSERIAL PRIMARY KEY,
    updated_on                              TIMESTAMP WITH TIME ZONE NOT NULL   
                                            CONSTRAINT exchange_rates_updated_on_df 
                                            DEFAULT(NOW()),
    office_id                               integer NOT NULL REFERENCES core.offices,
    status                                  BOOLEAN NOT NULL   
                                            CONSTRAINT exchange_rates_status_df 
                                            DEFAULT(true)
);

CREATE TABLE finance.exchange_rate_details
(
    exchange_rate_detail_id                 BIGSERIAL PRIMARY KEY,
    exchange_rate_id                        bigint NOT NULL REFERENCES finance.exchange_rates,
    local_currency_code                     national character varying(12) NOT NULL REFERENCES core.currencies,
    foreign_currency_code                   national character varying(12) NOT NULL REFERENCES core.currencies,
    unit                                    integer_strict NOT NULL,
    exchange_rate                           decimal_strict NOT NULL
);


DROP TYPE IF EXISTS finance.period CASCADE;

CREATE TYPE finance.period AS
(
    period_name                     text,
    date_from                       date,
    date_to                         date
);

CREATE TABLE finance.journal_verification_policy
(
    journal_verification_policy_id          SERIAL PRIMARY KEY,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    can_verify                              boolean NOT NULL DEFAULT(false),
    verification_limit                      public.money_strict2 NOT NULL DEFAULT(0),
    can_self_verify                         boolean NOT NULL DEFAULT(false),
    self_verification_limit                 money_strict2 NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               boolean NOT NULL,
	audit_user_id                       	integer NULL REFERENCES account.users,            
	audit_ts                            	TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)            
);


CREATE TABLE finance.auto_verification_policy
(
    auto_verification_policy_id             SERIAL PRIMARY KEY,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    verification_limit                      public.money_strict2 NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               boolean NOT NULL,
	audit_user_id                       	integer NULL REFERENCES account.users,            
	audit_ts                            	TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)                                            
);

CREATE TABLE finance.tax_setups
(
	tax_setup_id							SERIAL PRIMARY KEY,
	office_id								integer NOT NULL REFERENCES core.offices,
	income_tax_rate							public.decimal_strict NOT NULL,
	income_tax_account_id					integer NOT NULL REFERENCES finance.accounts,
	sales_tax_rate							public.decimal_strict NOT NULL,
	sales_tax_account_id					integer NOT NULL REFERENCES finance.accounts,
	audit_user_id                       	integer NULL REFERENCES account.users,
	audit_ts                            	TIMESTAMP WITH TIME ZONE DEFAULT(NOW()),
	deleted									boolean DEFAULT(false)
);

CREATE UNIQUE INDEX tax_setup_office_id_uix
ON finance.tax_setups(office_id)
WHERE NOT finance.tax_setups.deleted;


CREATE TABLE finance.routines
(
    routine_id                              SERIAL NOT NULL PRIMARY KEY,
    "order"                                 integer NOT NULL,
    routine_code                            national character varying(48) NOT NULL,
    routine_name                            regproc NOT NULL UNIQUE,
    status                                  boolean NOT NULL CONSTRAINT routines_status_df DEFAULT(true)
);

CREATE UNIQUE INDEX routines_routine_code_uix
ON finance.routines(LOWER(routine_code));

CREATE TABLE finance.day_operation
(
    day_id                                  BIGSERIAL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices,
    value_date                              date NOT NULL,
    started_on                              TIMESTAMP WITH TIME ZONE NOT NULL,
    started_by                              integer NOT NULL REFERENCES account.users,    
    completed_on                            TIMESTAMP WITH TIME ZONE NULL,
    completed_by                            integer NULL REFERENCES account.users,
    completed                               boolean NOT NULL 
                                            CONSTRAINT day_operation_completed_df DEFAULT(false)
                                            CONSTRAINT day_operation_completed_chk 
                                            CHECK
                                            (
                                                (completed OR completed_on IS NOT NULL)
                                                OR
                                                (NOT completed OR completed_on IS NULL)
                                            )
);


CREATE UNIQUE INDEX day_operation_value_date_uix
ON finance.day_operation(value_date);

CREATE INDEX day_operation_completed_on_inx
ON finance.day_operation(completed_on);

CREATE TABLE finance.day_operation_routines
(
    day_operation_routine_id                BIGSERIAL NOT NULL PRIMARY KEY,
    day_id                                  bigint NOT NULL REFERENCES finance.day_operation,
    routine_id                              integer NOT NULL REFERENCES finance.routines,
    started_on                              TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_on                            TIMESTAMP WITH TIME ZONE NULL
);

CREATE INDEX day_operation_routines_started_on_inx
ON finance.day_operation_routines(started_on);

CREATE INDEX day_operation_routines_completed_on_inx
ON finance.day_operation_routines(completed_on);

