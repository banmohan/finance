DROP SCHEMA IF EXISTS finance CASCADE;
CREATE SCHEMA finance;


CREATE TABLE finance.cash_repositories
(
    cash_repository_id                      SERIAL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices(office_id),
    cash_repository_code                    national character varying(12) NOT NULL,
    cash_repository_name                    national character varying(50) NOT NULL,
    parent_cash_repository_id               integer NULL REFERENCES finance.cash_repositories(cash_repository_id),
    description                             national character varying(100) NULL,
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL DEFAULT(NOW())
);


CREATE UNIQUE INDEX cash_repositories_cash_repository_code_uix
ON finance.cash_repositories(office_id, UPPER(cash_repository_code));

CREATE UNIQUE INDEX cash_repositories_cash_repository_name_uix
ON finance.cash_repositories(office_id, UPPER(cash_repository_name));


CREATE TABLE finance.fiscal_year
(
    fiscal_year_code                        national character varying(12) PRIMARY KEY,
    fiscal_year_name                        national character varying(50) NOT NULL,
    starts_from                             date NOT NULL,
    ends_on                                 date NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL  
                                            DEFAULT(NOW())
);

CREATE UNIQUE INDEX fiscal_year_fiscal_year_name_uix
ON finance.fiscal_year(UPPER(fiscal_year_name));

CREATE UNIQUE INDEX fiscal_year_starts_from_uix
ON finance.fiscal_year(starts_from);

CREATE UNIQUE INDEX fiscal_year_ends_on_uix
ON finance.fiscal_year(ends_on);



CREATE TABLE finance.account_masters
(
    account_master_id                       smallint PRIMARY KEY,
    account_master_code                     national character varying(3) NOT NULL,
    account_master_name                     national character varying(40) NOT NULL,
    normally_debit                          boolean NOT NULL CONSTRAINT account_masters_normally_debit_df DEFAULT(false),
    parent_account_master_id                smallint NULL REFERENCES finance.account_masters(account_master_id)
);

CREATE UNIQUE INDEX account_master_code_uix
ON finance.account_masters(UPPER(account_master_code));

CREATE UNIQUE INDEX account_master_name_uix
ON finance.account_masters(UPPER(account_master_name));

CREATE INDEX account_master_parent_account_master_id_inx
ON finance.account_masters(parent_account_master_id);



CREATE TABLE finance.cost_centers
(
    cost_center_id                          SERIAL PRIMARY KEY,
    cost_center_code                        national character varying(24) NOT NULL,
    cost_center_name                        national character varying(50) NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL   
                                            DEFAULT(NOW())
);

CREATE UNIQUE INDEX cost_centers_cost_center_code_uix
ON finance.cost_centers(UPPER(cost_center_code));

CREATE UNIQUE INDEX cost_centers_cost_center_name_uix
ON finance.cost_centers(UPPER(cost_center_name));


CREATE TABLE finance.frequency_setups
(
    frequency_setup_id                      SERIAL PRIMARY KEY,
    fiscal_year_code                        national character varying(12) NOT NULL REFERENCES finance.fiscal_year(fiscal_year_code),
    frequency_setup_code                    national character varying(12) NOT NULL,
    value_date                              date NOT NULL UNIQUE,
    frequency_id                            integer NOT NULL REFERENCES core.frequencies(frequency_id),
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL  
                                            DEFAULT(NOW())
);

CREATE UNIQUE INDEX frequency_setups_frequency_setup_code_uix
ON finance.frequency_setups(UPPER(frequency_setup_code));



CREATE TABLE finance.accounts
(
    account_id                              BIGSERIAL PRIMARY KEY,
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters(account_master_id),
    account_number                          national character varying(12) NOT NULL,
    external_code                           national character varying(12) NULL CONSTRAINT accounts_external_code_df DEFAULT(''),
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies(currency_code),
    account_name                            national character varying(100) NOT NULL,
    description                             national character varying(200) NULL,
    confidential                            boolean NOT NULL CONSTRAINT accounts_confidential_df DEFAULT(false),
    is_transaction_node                     boolean NOT NULL --Non transaction nodes cannot be used in transaction.
                                            CONSTRAINT accounts_is_transaction_node_df DEFAULT(true),
    sys_type                                boolean NOT NULL CONSTRAINT accounts_sys_type_df DEFAULT(false),
    parent_account_id                       bigint NULL REFERENCES finance.accounts(account_id),
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL 
                                            DEFAULT(NOW())
);


CREATE UNIQUE INDEX accounts_account_number_uix
ON finance.accounts(UPPER(account_number));

CREATE UNIQUE INDEX accounts_name_uix
ON finance.accounts(UPPER(account_name));


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
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL 
                                            DEFAULT(NOW())
);

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_code_uix
ON finance.cash_flow_headings(UPPER(cash_flow_heading_code));

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_name_uix
ON finance.cash_flow_headings(UPPER(cash_flow_heading_code));



CREATE TABLE finance.bank_accounts
(
    account_id                              bigint PRIMARY KEY REFERENCES finance.accounts(account_id),                                            
    maintained_by_user_id                   integer NOT NULL REFERENCES account.users(user_id),
	is_merchant_account 					boolean NOT NULL DEFAULT(false),
    office_id                               integer NOT NULL REFERENCES core.offices(office_id),
    bank_name                               national character varying(128) NOT NULL,
    bank_branch                             national character varying(128) NOT NULL,
    bank_contact_number                     national character varying(128) NULL,
    bank_address                            text NULL,
    bank_account_number                     national character varying(128) NULL,
    bank_account_type                       national character varying(128) NULL,
    relationship_officer_name               national character varying(128) NULL,
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL   
                                            DEFAULT(NOW())
);

CREATE TABLE finance.transaction_types
(
    transaction_type_id                     smallint PRIMARY KEY,
    transaction_type_code                   national character varying(4),
    transaction_type_name                   national character varying(100)
);

CREATE UNIQUE INDEX transaction_types_transaction_type_code_uix
ON finance.transaction_types(UPPER(transaction_type_code));

CREATE UNIQUE INDEX transaction_types_transaction_type_name_uix
ON finance.transaction_types(UPPER(transaction_type_name));

INSERT INTO finance.transaction_types
SELECT 1, 'Any', 'Any (Debit or Credit)' UNION ALL
SELECT 2, 'Dr', 'Debit' UNION ALL
SELECT 3, 'Cr', 'Credit';



CREATE TABLE finance.cash_flow_setup
(
    cash_flow_setup_id                      SERIAL PRIMARY KEY,
    cash_flow_heading_id                    integer NOT NULL REFERENCES finance.cash_flow_headings(cash_flow_heading_id),
    account_master_id                       smallint NOT NULL REFERENCES finance.account_masters(account_master_id),
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL 
                                            DEFAULT(NOW())
);

CREATE INDEX cash_flow_setup_cash_flow_heading_id_inx
ON finance.cash_flow_setup(cash_flow_heading_id);

CREATE INDEX cash_flow_setup_account_master_id_inx
ON finance.cash_flow_setup(account_master_id);



CREATE TABLE finance.transaction_master
(
    transaction_master_id                   BIGSERIAL PRIMARY KEY,
    transaction_counter                     integer NOT NULL, --Sequence of transactions of a date
    transaction_code                        national character varying(50) NOT NULL,
    book                                    national character varying(50) NOT NULL, --Transaction book. Ex. Sales, Purchase, Journal
    value_date                              date NOT NULL,
    transaction_ts                          TIMESTAMP WITH TIME ZONE NOT NULL   
                                            DEFAULT(NOW()),
    login_id                                bigint NOT NULL REFERENCES account.logins(login_id),
    user_id                                 integer NOT NULL REFERENCES account.users(user_id),
    sys_user_id                             integer NULL REFERENCES account.users(user_id),
    office_id                               integer NOT NULL REFERENCES core.offices(office_id),
    cost_center_id                          integer NULL REFERENCES finance.cost_centers(cost_center_id),
    reference_number                        national character varying(24) NULL,
    statement_reference                     text NULL,
    last_verified_on                        TIMESTAMP WITH TIME ZONE NULL, 
    verified_by_user_id                     integer NULL REFERENCES account.users(user_id),
    verification_status_id                  smallint NOT NULL REFERENCES core.verification_statuses(verification_status_id)   
                                            DEFAULT(0/*Awaiting verification*/),
    verification_reason                     national character varying(128) NOT NULL   
                                            CONSTRAINT transaction_master_verification_reason_df   
                                            DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL                                               
                                            DEFAULT(NOW()),
                                            CONSTRAINT transaction_master_login_id_sys_user_id_chk
                                                CHECK
                                                (
                                                    (
                                                        login_id IS NULL AND sys_user_id IS NOT NULL
                                                    )

                                                    OR

                                                    (
                                                        login_id IS NOT NULL AND sys_user_id IS NULL
                                                    )
                                                )
);

CREATE UNIQUE INDEX transaction_master_transaction_code_uix
ON finance.transaction_master(UPPER(transaction_code));



CREATE TABLE finance.transaction_details
(
    transaction_detail_id                   BIGSERIAL PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master(transaction_master_id),
    value_date                              date NOT NULL,
    tran_type                               national character varying(4) NOT NULL CHECK(tran_type IN ('Dr', 'Cr')),
    account_id                              bigint NOT NULL REFERENCES finance.accounts(account_id),
    statement_reference                     text NULL,
    cash_repository_id                      integer NULL REFERENCES finance.cash_repositories(cash_repository_id),
    currency_code                           national character varying(12) NULL REFERENCES core.currencies(currency_code),
    amount_in_currency                      money_strict NOT NULL,
    local_currency_code                     national character varying(12) NULL REFERENCES core.currencies(currency_code),
    er                                      decimal_strict NOT NULL,
    amount_in_local_currency                money_strict NOT NULL,  
    audit_user_id                           integer NULL REFERENCES account.users(user_id),
    audit_ts                                TIMESTAMP WITH TIME ZONE NULL   
                                            DEFAULT(NOW())
);


CREATE TABLE finance.day_operation
(
    day_id                                  BIGSERIAL NOT NULL PRIMARY KEY,
    office_id                               integer NOT NULL REFERENCES core.offices(office_id),
    value_date                              date NOT NULL,
    started_on                              TIMESTAMP WITH TIME ZONE NOT NULL,
    started_by                              integer NOT NULL REFERENCES account.users(user_id),    
    completed_on                            TIMESTAMP WITH TIME ZONE NULL,
    completed_by                            integer NULL REFERENCES account.users(user_id),
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

CREATE TABLE finance.card_types
(
	card_type_id                    integer PRIMARY KEY,
	card_type_code                  national character varying(12) NOT NULL,
	card_type_name                  national character varying(100) NOT NULL
);

CREATE UNIQUE INDEX card_types_card_type_code_uix
ON finance.card_types(UPPER(card_type_code));

CREATE UNIQUE INDEX card_types_card_type_name_uix
ON finance.card_types(UPPER(card_type_name));

CREATE TABLE finance.payment_cards
(
	payment_card_id                     	SERIAL NOT NULL PRIMARY KEY,
	payment_card_code                   	national character varying(12) NOT NULL,
	payment_card_name                   	national character varying(100) NOT NULL,
	card_type_id                        	integer NOT NULL REFERENCES finance.card_types(card_type_id),            
	audit_user_id                       	integer NULL REFERENCES account.users(user_id),            
	audit_ts                            	TIMESTAMP WITH TIME ZONE NULL 
											DEFAULT(NOW())            
);

CREATE UNIQUE INDEX payment_cards_payment_card_code_uix
ON finance.payment_cards(UPPER(payment_card_code));

CREATE UNIQUE INDEX payment_cards_payment_card_name_uix
ON finance.payment_cards(UPPER(payment_card_name));    


CREATE TABLE finance.merchant_fee_setup
(
	merchant_fee_setup_id               SERIAL NOT NULL PRIMARY KEY,
	merchant_account_id                 bigint NOT NULL REFERENCES finance.bank_accounts(account_id),
	payment_card_id                     integer NOT NULL REFERENCES finance.payment_cards(payment_card_id),
	rate                                public.decimal_strict NOT NULL,
	customer_pays_fee                   boolean NOT NULL DEFAULT(false),
	account_id                          bigint NOT NULL REFERENCES finance.accounts(account_id),
	statement_reference                 national character varying(128) NOT NULL DEFAULT(''),
	audit_user_id                       integer NULL REFERENCES account.users(user_id),            
	audit_ts                            TIMESTAMP WITH TIME ZONE NULL 
										DEFAULT(NOW())            
);

CREATE UNIQUE INDEX merchant_fee_setup_merchant_account_id_payment_card_id_uix
ON finance.merchant_fee_setup(merchant_account_id, payment_card_id);


DROP TYPE IF EXISTS finance.period CASCADE;

CREATE TYPE finance.period AS
(
    period_name                     text,
    date_from                       date,
    date_to                         date
);