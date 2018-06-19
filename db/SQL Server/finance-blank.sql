-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.auto_verify.sql --<--<--
IF OBJECT_ID('finance.auto_verify') IS NOT NULL
DROP PROCEDURE finance.auto_verify;

GO


CREATE PROCEDURE finance.auto_verify
(
    @tran_id        bigint,
    @office_id      integer
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @transaction_master_id          bigint= @tran_id;
    DECLARE @transaction_posted_by          integer;
    DECLARE @verifier                       integer;
    DECLARE @status                         integer = 1;
    DECLARE @reason                         national character varying(128) = 'Automatically verified';
    DECLARE @rejected                       smallint=-3;
    DECLARE @closed                         smallint=-2;
    DECLARE @withdrawn                      smallint=-1;
    DECLARE @unapproved                     smallint = 0;
    DECLARE @auto_approved                  smallint = 1;
    DECLARE @approved                       smallint=2;
    DECLARE @book                           national character varying(50);
    DECLARE @verification_limit             numeric(30, 6);
    DECLARE @posted_amount                  numeric(30, 6);
    DECLARE @has_policy                     bit= 0;
    DECLARE @voucher_date                   date;

    SELECT
        @book = finance.transaction_master.book,
        @voucher_date = finance.transaction_master.value_date,
        @transaction_posted_by = finance.transaction_master.user_id          
    FROM finance.transaction_master
    WHERE finance.transaction_master.transaction_master_id = @transaction_master_id
    AND finance.transaction_master.deleted = 0;
    
    SELECT
        @posted_amount = SUM(amount_in_local_currency)        
    FROM
        finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = @transaction_master_id
    AND finance.transaction_details.tran_type='Cr';


    SELECT
        @has_policy = 1,
        @verification_limit = verification_limit
    FROM finance.auto_verification_policy
    WHERE finance.auto_verification_policy.user_id = @transaction_posted_by
    AND finance.auto_verification_policy.office_id = @office_id
    AND finance.auto_verification_policy.is_active= 1
    AND GETUTCDATE() >= effective_from
    AND GETUTCDATE() <= ends_on
    AND finance.auto_verification_policy.deleted = 0;

    IF(@has_policy= 1)
    BEGIN
        UPDATE finance.transaction_master
        SET 
            last_verified_on = GETUTCDATE(),
            verified_by_user_id=@verifier,
            verification_status_id=@status,
            verification_reason=@reason
        WHERE
            finance.transaction_master.transaction_master_id=@transaction_master_id
        OR
            finance.transaction_master.cascading_tran_id=@transaction_master_id
        OR
        finance.transaction_master.transaction_master_id = 
        (
            SELECT cascading_tran_id
            FROM finance.transaction_master
            WHERE finance.transaction_master.transaction_master_id=@transaction_master_id 
        );
    END
    ELSE
    BEGIN
		--RAISERROR('No auto verification policy found for this user.', 13, 1);
		PRINT 'No auto verification policy found for this user.';
    END;
    RETURN;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.can_post_transaction.sql --<--<--
IF OBJECT_ID('finance.can_post_transaction') IS NOT NULL
DROP FUNCTION finance.can_post_transaction;

GO

CREATE FUNCTION finance.can_post_transaction(@login_id bigint, @user_id integer, @office_id integer, @transaction_book national character varying(50), @value_date date)
RETURNS @result TABLE
(
	can_post_transaction						bit,
	error_message								national character varying(1000)
)
AS
BEGIN
	INSERT INTO @result
	SELECT 0, '';

    DECLARE @eod_required                       bit		= finance.eod_required(@office_id);
    DECLARE @fiscal_year_start_date             date    = finance.get_fiscal_year_start_date(@office_id);
    DECLARE @fiscal_year_end_date               date    = finance.get_fiscal_year_end_date(@office_id);

    IF(account.is_valid_login_id(@login_id) = 0)
    BEGIN
		UPDATE @result
		SET error_message =  'Invalid LoginId.';
		RETURN;
    END; 

    IF(core.is_valid_office_id(@office_id) = 0)
    BEGIN
        UPDATE @result
		SET error_message =  'Invalid OfficeId.';
		RETURN;
    END;

    IF(finance.is_transaction_restricted(@office_id) = 1)
    BEGIN
        UPDATE @result
		SET error_message = 'This establishment does not allow transaction posting.';
		RETURN;
    END;
    
    IF(@eod_required = 1)
    BEGIN
        IF(finance.is_restricted_mode() = 1)
        BEGIN
            UPDATE @result
			SET error_message = 'Cannot post transaction during restricted transaction mode.';
			RETURN;
        END;

        IF(@value_date < finance.get_value_date(@office_id))
        BEGIN
            UPDATE @result
			SET error_message = 'Past dated transactions are not allowed.';
			RETURN;
        END;
    END;

    IF(@value_date < @fiscal_year_start_date)
    BEGIN
        UPDATE @result
		SET error_message = 'You cannot post transactions before the current fiscal year start date.';
		RETURN;
    END;

    IF(@value_date > @fiscal_year_end_date)
    BEGIN
        UPDATE @result
		SET error_message = 'You cannot post transactions after the current fiscal year end date.';

		RETURN;
    END;
    
    IF NOT EXISTS 
    (
        SELECT *
        FROM account.users
        INNER JOIN account.roles
        ON account.users.role_id = account.roles.role_id
        AND user_id = @user_id
    )
    BEGIN
        UPDATE @result
		SET error_message = 'Access is denied. You are not authorized to post this transaction.';
    END;
	
	UPDATE @result SET error_message = '', can_post_transaction = 1;

    RETURN;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.convert_exchange_rate.sql --<--<--
IF OBJECT_ID('finance.convert_exchange_rate') IS NOT NULL
DROP FUNCTION finance.convert_exchange_rate;

GO

CREATE FUNCTION finance.convert_exchange_rate(@office_id integer, @source_currency_code national character varying(12), @destination_currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @unit                           integer = 0;
    DECLARE @exchange_rate                  numeric(30, 6) = 0;
    DECLARE @from_source_currency           numeric(30, 6) = finance.get_exchange_rate(@office_id, @source_currency_code);
    DECLARE @from_destination_currency      numeric(30, 6) = finance.get_exchange_rate(@office_id, @destination_currency_code);

    IF(@source_currency_code = @destination_currency_code)
    BEGIN
        RETURN 1;
    END;
        
	IF(@from_destination_currency = 0)
	BEGIN
		RETURN NULL;
	END;

    RETURN @from_source_currency / @from_destination_currency; 
END;

GO

--SELECT  finance.convert_exchange_rate(1, 'USD', 'NPR')


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.create_card_type.sql --<--<--
IF OBJECT_ID('finance.create_card_type') IS NOT NULL
DROP PROCEDURE finance.create_card_type;

GO

CREATE PROCEDURE finance.create_card_type
(
    @card_type_id       integer, 
    @card_type_code     national character varying(12),
    @card_type_name     national character varying(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT * FROM finance.card_types
        WHERE card_type_id = @card_type_id
    )
	BEGIN
        INSERT INTO finance.card_types(card_type_id, card_type_code, card_type_name)
        SELECT @card_type_id, @card_type_code, @card_type_name;
		
		RETURN;
	END

    UPDATE finance.card_types
    SET 
        card_type_id =      @card_type_id, 
        card_type_code =    @card_type_code, 
        card_type_name =    @card_type_name
    WHERE card_type_id =      @card_type_id;
END

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.create_routine.sql --<--<--
IF OBJECT_ID('finance.create_routine') IS NOT NULL
DROP PROCEDURE finance.create_routine;

GO

CREATE PROCEDURE finance.create_routine(@routine_code national character varying(12), @routine national character varying(128), @order integer)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS(SELECT * FROM finance.routines WHERE routine_code=@routine_code)
    BEGIN
        INSERT INTO finance.routines(routine_code, routine_name, "order")
        SELECT @routine_code, @routine, @order
        RETURN;
    END;

    UPDATE finance.routines
    SET
        routine_name = @routine,
        "order" = @order
    WHERE routine_code=@routine_code;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.date_functions.sql --<--<--
IF OBJECT_ID('finance.get_date') IS NOT NULL
DROP FUNCTION finance.get_date;
GO

CREATE FUNCTION finance.get_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN finance.get_value_date(@office_id);
END;


GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

CREATE FUNCTION finance.get_month_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    );
END;




GO

IF OBJECT_ID('finance.get_month_start_date') IS NOT NULL
DROP FUNCTION finance.get_month_start_date;

GO

CREATE FUNCTION finance.get_month_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @date;
END;



GO

IF OBJECT_ID('finance.get_quarter_end_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_end_date;

GO

CREATE FUNCTION finance.get_quarter_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 2
        AND finance.frequency_setups.deleted = 0
    );
END;




GO

IF OBJECT_ID('finance.get_quarter_start_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date;

GO

CREATE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND frequency_id > 2
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @date;
END;



GO

IF OBJECT_ID('finance.get_fiscal_half_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_end_date;

GO

CREATE FUNCTION finance.get_fiscal_half_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 3
        AND finance.frequency_setups.deleted = 0
    );
END;




GO

IF OBJECT_ID('finance.get_fiscal_half_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_start_date;

GO

CREATE FUNCTION finance.get_fiscal_half_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.deleted = 0
    )
    AND frequency_id > 3
    AND finance.frequency_setups.deleted = 0;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @date;
END;



GO

IF OBJECT_ID('finance.get_fiscal_year_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_end_date;

GO

CREATE FUNCTION finance.get_fiscal_year_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 4
        AND finance.frequency_setups.deleted = 0
    );
END;



GO

IF OBJECT_ID('finance.get_fiscal_year_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_start_date;

GO

CREATE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = starts_from
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.deleted = 0;

    RETURN @date;
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.eod_required.sql --<--<--
IF OBJECT_ID('finance.eod_required') IS NOT NULL
DROP FUNCTION finance.eod_required;

GO

CREATE FUNCTION finance.eod_required(@office_id integer)
RETURNS bit
AS
BEGIN
	DECLARE @value_date date = finance.get_value_date(@office_id);

    RETURN
    (
	    SELECT finance.fiscal_year.eod_required
	    FROM finance.fiscal_year
	    WHERE finance.fiscal_year.office_id = @office_id
		AND finance.fiscal_year.deleted = 0
		AND finance.fiscal_year.starts_from >= @value_date
		AND finance.fiscal_year.ends_on <= @value_date
    );
END;

GO

--SELECT finance.eod_required(1);


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_id_by_account_name.sql --<--<--
IF OBJECT_ID('finance.get_account_id_by_account_name') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_account_name;

GO

CREATE FUNCTION finance.get_account_id_by_account_name(@account_name national character varying(500))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        account_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_name=@account_name
	    AND finance.accounts.deleted = 0
	);
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_id_by_account_number.sql --<--<--
IF OBJECT_ID('finance.get_account_id_by_account_number') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_account_number;

GO

CREATE FUNCTION finance.get_account_id_by_account_number(@account_number national character varying(500))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        account_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_number=@account_number
	    AND finance.accounts.deleted = 0
	);
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_id_by_bank_account_id.sql --<--<--
IF OBJECT_ID('finance.get_account_id_by_bank_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_id_by_bank_account_id;

GO

CREATE FUNCTION finance.get_account_id_by_bank_account_id(@bank_account_id integer)
RETURNS integer
AS
BEGIN
	RETURN
	(
		SELECT account_id 
		FROM finance.bank_accounts
		WHERE bank_account_id = @bank_account_id
		AND deleted = 0
	);
END;

GO

--SELECT finance.get_account_id_by_bank_account_id(1);



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_ids.sql --<--<--
IF OBJECT_ID('finance.get_account_ids') IS NOT NULL
DROP FUNCTION finance.get_account_ids;

GO

CREATE FUNCTION finance.get_account_ids(@root_account_id integer)
RETURNS @result TABLE
(
    account_id              integer
)
AS
BEGIN
    WITH account_cte(account_id, path) AS 
    (
        SELECT
            tn.account_id,  CAST(tn.account_id AS varchar(2000)) AS path
        FROM finance.accounts AS tn 
        WHERE tn.account_id = @root_account_id
        AND tn.deleted = 0

        UNION ALL

        SELECT
            c.account_id, CAST((p.path + '->' + CAST(c.account_id AS varchar(50))) AS varchar(2000))
        FROM account_cte AS p, finance.accounts AS c WHERE parent_account_id = p.account_id
    )

    INSERT INTO @result
    SELECT account_id FROM account_cte
    RETURN;
END;
GO

--SELECT * FROM finance.get_account_ids(1);



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_master_id_by_account_id.sql --<--<--
IF OBJECT_ID('finance.get_account_master_id_by_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_master_id_by_account_id;

GO

CREATE FUNCTION finance.get_account_master_id_by_account_id(@account_id integer)
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT finance.accounts.account_master_id
	    FROM finance.accounts
	    WHERE finance.accounts.account_id=@account_id
	    AND finance.accounts.deleted = 0
    );
END;

GO

ALTER TABLE finance.bank_accounts
ADD CONSTRAINT bank_accounts_account_id_chk 
CHECK
(
    finance.get_account_master_id_by_account_id(account_id) = '10102'
);

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_master_id_by_account_master_code.sql --<--<--
IF OBJECT_ID('finance.get_account_master_id_by_account_master_code') IS NOT NULL
DROP FUNCTION finance.get_account_master_id_by_account_master_code;

GO

CREATE FUNCTION finance.get_account_master_id_by_account_master_code(@account_master_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT finance.account_masters.account_master_id
	    FROM finance.account_masters
	    WHERE finance.account_masters.account_master_code = @account_master_code
	    AND finance.account_masters.deleted = 0
    );
END;





GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_master_ids.sql --<--<--
IF OBJECT_ID('finance.get_account_master_ids') IS NOT NULL
DROP FUNCTION finance.get_account_master_ids;

GO

CREATE FUNCTION finance.get_account_master_ids(@root_account_master_id integer)
RETURNS @result TABLE
(
    account_master_id              integer
)
AS
BEGIN
    WITH account_cte(account_master_id, path) AS 
    (
        SELECT
            tn.account_master_id,  CAST(tn.account_master_id AS varchar(2000)) AS path
        FROM finance.account_masters AS tn 
        WHERE tn.account_master_id = @root_account_master_id
        AND tn.deleted = 0

        UNION ALL

        SELECT
            c.account_master_id, CAST((p.path + '->' + CAST(c.account_master_id AS varchar(50))) AS varchar(2000))
        FROM account_cte AS p, finance.account_masters AS c WHERE parent_account_master_id = p.account_master_id
    )

    INSERT INTO @result
    SELECT account_master_id FROM account_cte
    RETURN;
END;
GO

--SELECT * FROM finance.get_account_master_ids(1);



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_name.sql --<--<--
IF OBJECT_ID('finance.get_account_name_by_account_id') IS NOT NULL
DROP FUNCTION finance.get_account_name_by_account_id;

GO

CREATE FUNCTION finance.get_account_name_by_account_id(@account_id integer)
RETURNS national character varying(500)
AS
BEGIN
    RETURN
    (
	    SELECT account_name
	    FROM finance.accounts
	    WHERE finance.accounts.account_id=@account_id
	    AND finance.accounts.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_statement.sql --<--<--
IF OBJECT_ID('finance.get_account_statement') IS NOT NULL
DROP FUNCTION finance.get_account_statement;

GO

CREATE FUNCTION finance.get_account_statement
(
    @value_date_from        date,
    @value_date_to          date,
    @user_id                integer,
    @account_id             integer,
    @office_id              integer
)
RETURNS @result TABLE
(
    id                      integer IDENTITY,
	transaction_id			bigint,
	transaction_detail_id	bigint,
    value_date              date,
    book_date               date,
    tran_code               national character varying(50),
    reference_number        national character varying(24),
    statement_reference     national character varying(2000),
    reconciliation_memo     national character varying(2000),
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    balance                 numeric(30, 6),
    office 					national character varying(1000),
    book                    national character varying(50),
    account_id              integer,
    account_number 			national character varying(24),
    account                 national character varying(1000),
    posted_on               DATETIMEOFFSET,
    posted_by               national character varying(1000),
    approved_by             national character varying(1000),
    verification_status     integer
)
AS
BEGIN
    DECLARE @normally_debit bit = finance.is_normally_debit(@account_id);

    INSERT INTO @result(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        @value_date_from,
        @value_date_from,
        NULL,
        NULL,
        'Opening Balance',
        NULL,
        SUM
        (
            CASE finance.transaction_details.tran_type
            WHEN 'Cr' THEN amount_in_local_currency
            ELSE amount_in_local_currency * -1 
            END            
        ) as credit,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date < @value_date_from
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.transaction_master.deleted = 0;

    DELETE FROM @result
    WHERE COALESCE(debit, 0) = 0
    AND COALESCE(credit, 0) = 0;
    

    UPDATE @result SET 
    debit = credit * -1,
    credit = 0
    WHERE credit < 0;
    

    INSERT INTO @result(transaction_id, transaction_detail_id, value_date, book_date, tran_code, reference_number, statement_reference, reconciliation_memo, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
		finance.transaction_details.transaction_master_id,
		finance.transaction_details.transaction_detail_id,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master. transaction_code,
        finance.transaction_master.reference_number,
        finance.transaction_details.statement_reference,
		finance.transaction_details.reconciliation_memo,
        CASE finance.transaction_details.tran_type
        WHEN 'Dr' THEN amount_in_local_currency
        ELSE NULL END,
        CASE finance.transaction_details.tran_type
        WHEN 'Cr' THEN amount_in_local_currency
        ELSE NULL END,
        core.get_office_name_by_office_id(finance.transaction_master.office_id),
        finance.transaction_master.book,
        finance.transaction_details.account_id,
        finance.transaction_master.transaction_ts,
        account.get_name_by_user_id(finance.transaction_master.user_id),
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id),
        finance.transaction_master.verification_status_id
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE finance.transaction_master.verification_status_id > 0
    AND finance.transaction_master.value_date >= @value_date_from
    AND finance.transaction_master.value_date <= @value_date_to
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM finance.get_account_ids(@account_id))
    AND finance.transaction_master.deleted = 0
    ORDER BY 
        finance.transaction_master.value_date,
        finance.transaction_master.transaction_ts,
        finance.transaction_master.book_date,
        finance.transaction_master.last_verified_on;



    UPDATE result
    SET balance = c.balance
    FROM @result AS result
    INNER JOIN
    (
        SELECT
            temp_account_statement.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM @result AS temp_account_statement
        LEFT JOIN @result AS c 
            ON (c.id <= temp_account_statement.id)
        GROUP BY temp_account_statement.id
    ) AS c
    ON result.id = c.id;


    UPDATE result SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM @result AS result
    INNER JOIN finance.accounts
    ON result.account_id = finance.accounts.account_id;



    IF(@normally_debit = 1)
    BEGIN
        UPDATE @result SET balance = balance * -1;
    END;

    RETURN;
END;





GO

--SELECT * FROM finance.get_account_statement('1-1-2010','1-1-2020',1,1,1);


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_view_by_account_master_id.sql --<--<--
IF OBJECT_ID('finance.get_account_view_by_account_master_id') IS NOT NULL
DROP FUNCTION finance.get_account_view_by_account_master_id;

GO

CREATE FUNCTION finance.get_account_view_by_account_master_id
(
    @account_master_id      integer,
    @row_number             integer
)
RETURNS @results table
(
    id                      bigint,
    account_id              integer,
    account_name            text    
)
AS
BEGIN
    INSERT INTO @results
    SELECT ROW_NUMBER() OVER (ORDER BY accounts.account_id) + @row_number AS id, * FROM 
    (
        SELECT 
			finance.accounts.account_id, 
			finance.get_account_name_by_account_id(finance.accounts.account_id) AS account_name
        FROM finance.accounts
        WHERE finance.accounts.account_master_id = @account_master_id
    ) AS accounts;    
	
	RETURN;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_flow_heading_id_by_cash_flow_heading_code.sql --<--<--
IF OBJECT_ID('finance.get_cash_flow_heading_id_by_cash_flow_heading_code') IS NOT NULL
DROP FUNCTION finance.get_cash_flow_heading_id_by_cash_flow_heading_code;

GO

CREATE FUNCTION finance.get_cash_flow_heading_id_by_cash_flow_heading_code(@cash_flow_heading_code national character varying(12))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT
	        cash_flow_heading_id
	    FROM finance.cash_flow_headings
	    WHERE finance.cash_flow_headings.cash_flow_heading_code = @cash_flow_heading_code
	    AND finance.cash_flow_headings.deleted = 0
	);
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_repository_balance.sql --<--<--

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_repository_balance.sql --<--<--
IF OBJECT_ID('finance.get_cash_repository_balance') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_balance;

GO

CREATE FUNCTION finance.get_cash_repository_balance(@cash_repository_id integer, @currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @debit numeric(30, 6);
    DECLARE @credit numeric(30, 6);

    SELECT @debit = COALESCE(SUM(amount_in_currency), 0)
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Dr';

    SELECT @credit = COALESCE(SUM(amount_in_currency), 0)
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Cr';

    RETURN @debit - @credit;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_repository_id_by_cash_repository_code.sql --<--<--
IF OBJECT_ID('finance.get_cash_repository_id_by_cash_repository_code') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_id_by_cash_repository_code;

GO


CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_code(@cash_repository_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_code=@cash_repository_code
        AND finance.cash_repositories.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_repository_id_by_cash_repository_name.sql --<--<--
IF OBJECT_ID('finance.get_cash_repository_id_by_cash_repository_name') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_id_by_cash_repository_name;

GO

CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_name(@cash_repository_name national character varying(500))
RETURNS integer
AS

BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_name=@cash_repository_name
        AND finance.cash_repositories.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cost_center_id_by_cost_center_code.sql --<--<--
IF OBJECT_ID('finance.get_cost_center_id_by_cost_center_code') IS NOT NULL
DROP FUNCTION finance.get_cost_center_id_by_cost_center_code;

GO

CREATE FUNCTION finance.get_cost_center_id_by_cost_center_code(@cost_center_code national character varying(24))
RETURNS integer
AS
BEGIN
    RETURN
    (
	    SELECT cost_center_id
	    FROM finance.cost_centers
	    WHERE finance.cost_centers.cost_center_code=@cost_center_code
	    AND finance.cost_centers.deleted = 0
    );
END;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_default_currency_code.sql --<--<--
IF OBJECT_ID('finance.get_default_currency_code') IS NOT NULL
DROP FUNCTION finance.get_default_currency_code;

GO

CREATE FUNCTION finance.get_default_currency_code(@cash_repository_id integer)
RETURNS national character varying(12)
AS

BEGIN
    RETURN
    (
        SELECT core.offices.currency_code 
        FROM finance.cash_repositories
        INNER JOIN core.offices
        ON core.offices.office_id = finance.cash_repositories.office_id
        WHERE finance.cash_repositories.cash_repository_id=@cash_repository_id
        AND finance.cash_repositories.deleted = 0    
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_default_currency_code_by_office_id.sql --<--<--
IF OBJECT_ID('finance.get_default_currency_code_by_office_id') IS NOT NULL
DROP FUNCTION finance.get_default_currency_code_by_office_id;

GO

CREATE FUNCTION finance.get_default_currency_code_by_office_id(@office_id integer)
RETURNS national character varying(12)
AS

BEGIN
    RETURN
    (
        SELECT core.offices.currency_code 
        FROM core.offices
        WHERE core.offices.office_id = @office_id
        AND core.offices.deleted = 0    
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_exchange_rate.sql --<--<--
IF OBJECT_ID('finance.get_exchange_rate') IS NOT NULL
DROP FUNCTION finance.get_exchange_rate;

GO

CREATE FUNCTION finance.get_exchange_rate(@office_id integer, @currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @local_currency_code        national character varying(12)= '';
    DECLARE @unit                       integer = 0;
    DECLARE @exchange_rate              numeric(30, 6) = 0;

    SELECT @local_currency_code = core.offices.currency_code
    FROM core.offices
    WHERE core.offices.office_id=@office_id
    AND core.offices.deleted = 0;

    IF(@local_currency_code = @currency_code)
    BEGIN
        RETURN 1;
    END;

    SELECT 
        @unit = unit, 
        @exchange_rate = exchange_rate
    FROM finance.exchange_rate_details
    INNER JOIN finance.exchange_rates
    ON finance.exchange_rate_details.exchange_rate_id = finance.exchange_rates.exchange_rate_id
    WHERE finance.exchange_rates.office_id=@office_id
    AND foreign_currency_code=@currency_code;

    IF(@unit = 0)
    BEGIN
        RETURN 0;
    END;
    
    RETURN @exchange_rate/@unit;    
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequencies.sql --<--<--
IF OBJECT_ID('finance.get_frequencies') IS NOT NULL
DROP FUNCTION finance.get_frequencies;

GO

CREATE FUNCTION  finance.get_frequencies(@frequency_id integer)
RETURNS @t TABLE
(
    frequency_id    integer
)
AS
BEGIN
    IF(@frequency_id = 2)
    BEGIN
        --End of month
        --End of quarter is also end of third/ninth month
        --End of half is also end of sixth month
        --End of year is also end of twelfth month
        INSERT INTO @t
        SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 3)
    BEGIN

        --End of quarter
        --End of half is the second end of quarter
        --End of year is the fourth/last end of quarter
        INSERT INTO @t
        SELECT 3 UNION SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 4)
    BEGIN
        --End of half
        --End of year is the second end of half
        INSERT INTO @t
        SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 5)
    BEGIN
        --End of year
        INSERT INTO @t
        SELECT 5;
    END;

    RETURN;
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequency_end_date.sql --<--<--
IF OBJECT_ID('finance.get_frequency_end_date') IS NOT NULL
DROP FUNCTION finance.get_frequency_end_date;

GO

CREATE FUNCTION finance.get_frequency_end_date(@frequency_id integer, @value_date date)
RETURNS date
AS
BEGIN
    DECLARE @end_date date;

    SELECT @end_date = MIN(value_date)
    FROM finance.frequency_setups
    WHERE value_date > @value_date
    AND frequency_id IN(SELECT finance.get_frequencies(@frequency_id));

    RETURN @end_date;
END;



--SELECT * FROM finance.get_frequency_end_date(1, '1-1-2000');

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequency_setup_code_by_frequency_setup_id.sql --<--<--
IF OBJECT_ID('finance.get_frequency_setup_code_by_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_code_by_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_code_by_frequency_setup_id(@frequency_setup_id integer)
RETURNS national character varying(24)
AS
BEGIN
    RETURN
    (
	    SELECT frequency_setup_code
	    FROM finance.frequency_setups
	    WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
	    AND finance.frequency_setups.deleted = 0
    );
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequency_setup_end_date_by_frequency_setup_id.sql --<--<--
IF OBJECT_ID('finance.get_frequency_setup_end_date_by_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_end_date_by_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_end_date_by_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
	    SELECT value_date
	    FROM finance.frequency_setups
	    WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
	    AND finance.frequency_setups.deleted = 0
    );
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequency_setup_start_date_by_frequency_setup_id.sql --<--<--
IF OBJECT_ID('finance.get_frequency_setup_start_date_by_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_start_date_by_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_start_date_by_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS
BEGIN
    DECLARE @start_date date;

    SELECT @start_date = DATEADD(day, 1, MAX(value_date)) 
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date < 
    (
        SELECT value_date
        FROM finance.frequency_setups
        WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@start_date IS NULL)
    BEGIN
        SELECT @start_date = starts_from 
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @start_date;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_frequency_setup_start_date_frequency_setup_id.sql --<--<--
IF OBJECT_ID('finance.get_frequency_setup_start_date_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_start_date_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS
BEGIN
    DECLARE @start_date date;

    SELECT @start_date = DATEADD(day, 1, MAX(value_date)) 
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date < 
    (
        SELECT value_date
        FROM finance.frequency_setups
        WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
        AND finance.frequency_setups.deleted = 0
    )
    AND finance.frequency_setups.deleted = 0;

    IF(@start_date IS NULL)
    BEGIN
        SELECT @start_date = starts_from 
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.deleted = 0;
    END;

    RETURN @start_date;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_income_tax_provison_amount.sql --<--<--
IF OBJECT_ID('finance.get_income_tax_provison_amount') IS NOT NULL
DROP FUNCTION finance.get_income_tax_provison_amount;

GO

CREATE FUNCTION finance.get_income_tax_provison_amount(@office_id integer, @profit numeric(30, 6), @balance numeric(30, 6))
RETURNS  numeric(30, 6)
AS
BEGIN
    DECLARE @rate real = finance.get_income_tax_rate(@office_id);

    IF(@profit <= 0)
    BEGIN
    	RETURN 0;
    END;

    RETURN
    (
        (@profit * @rate/100) - @balance
    );
END;

GO

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_income_tax_rate.sql --<--<--
IF OBJECT_ID('finance.get_income_tax_rate') IS NOT NULL
DROP FUNCTION finance.get_income_tax_rate;

GO

CREATE FUNCTION finance.get_income_tax_rate(@office_id integer)
RETURNS numeric(30, 6)
AS

BEGIN
    RETURN
    (
	    SELECT income_tax_rate
	    FROM finance.tax_setups
	    WHERE finance.tax_setups.office_id = @office_id
	    AND finance.tax_setups.deleted = 0
    );    
END;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_journal_view.sql --<--<--
IF OBJECT_ID('finance.get_journal_view') IS NOT NULL
DROP FUNCTION finance.get_journal_view;

GO

CREATE FUNCTION finance.get_journal_view
(
    @user_id                        integer,
    @office_id                      integer,
    @from                           date,
    @to                             date,
    @tran_id                        bigint,
    @tran_code                      national character varying(50),
    @book                           national character varying(50),
    @reference_number               national character varying(50),
    @statement_reference            national character varying(2000),
    @posted_by                      national character varying(50),
    @office                         national character varying(50),
    @status                         national character varying(12),
    @verified_by                    national character varying(50),
    @reason                         national character varying(128)
)
RETURNS @result TABLE
(
    transaction_master_id           bigint,
    transaction_code                national character varying(50),
    book                            national character varying(50),
    value_date                      date,
    book_date                          date,
    reference_number                national character varying(24),
    statement_reference             national character varying(2000),
    posted_by                       national character varying(1000),
    office national character varying(1000),
    status                          national character varying(1000),
    verified_by                     national character varying(1000),
    verified_on                     DATETIMEOFFSET,
    reason                          national character varying(128),
    transaction_ts                  DATETIMEOFFSET
)
AS

BEGIN
    WITH office_cte(office_id) AS 
    (
        SELECT @office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    INSERT INTO @result
    SELECT 
        finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code,
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number,
        finance.transaction_master.statement_reference,
        account.get_name_by_user_id(finance.transaction_master.user_id) as posted_by,
        core.get_office_name_by_office_id(finance.transaction_master.office_id) as office,
        finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) as status,
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) as verified_by,
        finance.transaction_master.last_verified_on AS verified_on,
        finance.transaction_master.verification_reason AS reason,    
        finance.transaction_master.transaction_ts
    FROM finance.transaction_master
    WHERE 1 = 1
    AND finance.transaction_master.value_date BETWEEN @from AND @to
    AND office_id IN (SELECT office_id FROM office_cte)
    AND (@tran_id = 0 OR @tran_id  = finance.transaction_master.transaction_master_id)
    AND LOWER(finance.transaction_master.transaction_code) LIKE '%' + LOWER(@tran_code) + '%' 
    AND LOWER(finance.transaction_master.book) LIKE '%' + LOWER(@book) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.reference_number), '') LIKE '%' + LOWER(@reference_number) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.statement_reference), '') LIKE '%' + LOWER(@statement_reference) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.verification_reason), '') LIKE '%' + LOWER(@reason) + '%' 
    AND LOWER(account.get_name_by_user_id(finance.transaction_master.user_id)) LIKE '%' + LOWER(@posted_by) + '%' 
    AND LOWER(core.get_office_name_by_office_id(finance.transaction_master.office_id)) LIKE '%' + LOWER(@office) + '%' 
    AND COALESCE(LOWER(finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id)), '') LIKE '%' + LOWER(@status) + '%' 
    AND COALESCE(LOWER(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id)), '') LIKE '%' + LOWER(@verified_by) + '%'    
    AND finance.transaction_master.deleted = 0
    ORDER BY value_date ASC, verification_status_id DESC;

    RETURN;
END;




--SELECT * FROM finance.get_journal_view(2,1,'1-1-2000','1-1-2020',0,'', 'Inventory Transfer', '', '','', '','','', '');



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_new_transaction_counter.sql --<--<--
IF OBJECT_ID('finance.get_new_transaction_counter') IS NOT NULL
DROP FUNCTION finance.get_new_transaction_counter;

GO

CREATE FUNCTION finance.get_new_transaction_counter(@value_date date)
RETURNS integer
AS
BEGIN
    DECLARE @ret_val integer;

    SELECT @ret_val = COALESCE(MAX(transaction_counter),0)
    FROM finance.transaction_master
    WHERE finance.transaction_master.value_date=@value_date
    AND finance.transaction_master.deleted = 0;

    IF @ret_val IS NULL
    BEGIN
        SET @ret_val = 1;
    END
    ELSE
    BEGIN
        SET @ret_val = @ret_val + 1;
    END;

    RETURN @ret_val;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_office_id_by_cash_repository_id.sql --<--<--
IF OBJECT_ID('finance.get_office_id_by_cash_repository_id') IS NOT NULL
DROP FUNCTION finance.get_office_id_by_cash_repository_id;

GO

CREATE FUNCTION finance.get_office_id_by_cash_repository_id(@cash_repository_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT office_id
	    FROM finance.cash_repositories
	    WHERE finance.cash_repositories.cash_repository_id=@cash_repository_id
	    AND finance.cash_repositories.deleted = 0
    );
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_periods.sql --<--<--
IF OBJECT_ID('finance.get_periods') IS NOT NULL
DROP FUNCTION finance.get_periods;

GO

CREATE FUNCTION finance.get_periods
(
    @date_from                      date,
    @date_to                        date
)
RETURNS @period
TABLE
(
    period_name                             national character varying(500),
    date_from                               date,
    date_to                                 date
)
AS
BEGIN
    DECLARE @frequency_setups_temp TABLE
    (
        frequency_setup_id      int,
        value_date              date
    );

    INSERT INTO @frequency_setups_temp
    SELECT frequency_setup_id, value_date
    FROM finance.frequency_setups
    WHERE finance.frequency_setups.value_date BETWEEN @date_from AND @date_to
    AND finance.frequency_setups.deleted = 0
    ORDER BY value_date;

    INSERT INTO @period
    SELECT
        finance.get_frequency_setup_code_by_frequency_setup_id(frequency_setup_id),
        finance.get_frequency_setup_start_date_by_frequency_setup_id(frequency_setup_id),
        finance.get_frequency_setup_end_date_by_frequency_setup_id(frequency_setup_id)
    FROM @frequency_setups_temp;

    RETURN;
END;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_retained_earnings_statement.sql --<--<--
IF OBJECT_ID('finance.get_retained_earnings_statement') IS NOT NULL
DROP FUNCTION finance.get_retained_earnings_statement;

GO

CREATE FUNCTION finance.get_retained_earnings_statement
(
    @date_to                        date,
    @office_id                      integer,
    @factor                         integer    
)
RETURNS @result TABLE
(
    id                              integer,
    value_date                      date,
    tran_code                       national character varying(50),
    statement_reference             national character varying(2000),
    debit                           numeric(30, 6),
    credit                          numeric(30, 6),
    balance                         numeric(30, 6),
    office                          national character varying(1000),
    book                            national character varying(50),
    account_id                      integer,
    account_number                  national character varying(24),
    account                         national character varying(1000),
    posted_on                       DATETIMEOFFSET,
    posted_by                       national character varying(1000),
    approved_by                     national character varying(1000),
    verification_status             integer
)
AS
BEGIN
    DECLARE @accounts TABLE
    (
        account_id                  integer
    );

    DECLARE @date_from              date;
    DECLARE @net_profit             numeric(30, 6) = 0;
    DECLARE @income_tax_rate        real           = 0;
    DECLARE @itp                    numeric(30, 6) = 0;

    SET @date_from                      = finance.get_fiscal_year_start_date(@office_id);
    SET @net_profit                     = finance.get_net_profit(@date_from, @date_to, @office_id, @factor, 0);
    SET @income_tax_rate                = finance.get_income_tax_rate(@office_id);

    IF(COALESCE(@factor , 0) = 0)
    BEGIN
        SET @factor                        = 1;
    END; 

    IF(@income_tax_rate != 0)
    BEGIN
        SET @itp                        = (@net_profit * @income_tax_rate) / (100 - @income_tax_rate);
    END;

    DECLARE @retained_earnings TABLE
    (
        id                          integer IDENTITY,
        value_date                  date,
        tran_code                   national character varying(50),
        statement_reference         national character varying(2000),
        debit                       numeric(30, 6),
        credit                      numeric(30, 6),
        balance                     numeric(30, 6),
        office                      national character varying(1000),
        book                        national character varying(50),
        account_id                  integer,
        account_number              national character varying(24),
        account                     national character varying(1000),
        posted_on                   DATETIMEOFFSET,
        posted_by                   national character varying(1000),
        approved_by                 national character varying(1000),
        verification_status         integer
    ) ;

    INSERT INTO @accounts
    SELECT finance.accounts.account_id
    FROM finance.accounts
    WHERE finance.accounts.account_master_id BETWEEN 15300 AND 15400;

    INSERT INTO @retained_earnings(value_date, tran_code, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        @date_from,
        NULL,
        'Beginning balance on this fiscal year.',
        NULL,
        SUM
        (
            CASE finance.transaction_details.tran_type
            WHEN 'Cr' THEN amount_in_local_currency
            ELSE amount_in_local_currency * -1 
            END            
        ) as credit,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE
        finance.transaction_master.verification_status_id > 0
    AND
        finance.transaction_master.value_date < @date_from
    AND
       finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND
       finance.transaction_details.account_id IN (SELECT * FROM @accounts);

    INSERT INTO @retained_earnings(value_date, tran_code, statement_reference, debit, credit)
    SELECT @date_to, '', 'Add: Net Profit as on ' + CAST(@date_to AS varchar(24)), 0, @net_profit;

    INSERT INTO @retained_earnings(value_date, tran_code, statement_reference, debit, credit)
    SELECT @date_to, '', 'Add: Income Tax provison.', 0, @itp;

--     DELETE FROM @retained_earnings
--     WHERE COALESCE(@retained_earnings.debit, 0) = 0
--     AND COALESCE(@retained_earnings.credit, 0) = 0;
    

    UPDATE @retained_earnings SET 
    debit = credit * -1,
    credit = 0
    WHERE credit < 0;


    INSERT INTO @retained_earnings(value_date, tran_code, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        finance.transaction_master.value_date,
        finance.transaction_master. transaction_code,
        finance.transaction_details.statement_reference,
        CASE finance.transaction_details.tran_type
        WHEN 'Dr' THEN amount_in_local_currency / @factor
        ELSE NULL END,
        CASE finance.transaction_details.tran_type
        WHEN 'Cr' THEN amount_in_local_currency / @factor
        ELSE NULL END,
        core.get_office_name_by_office_id(finance.transaction_master.office_id),
        finance.transaction_master.book,
        finance.transaction_details.account_id,
        finance.transaction_master.transaction_ts,
        account.get_name_by_user_id(finance.transaction_master.user_id),
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id),
        finance.transaction_master.verification_status_id
    FROM finance.transaction_master
    INNER JOIN finance.transaction_details
    ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
    WHERE
        finance.transaction_master.verification_status_id > 0
    AND
        finance.transaction_master.value_date >= @date_from
    AND
        finance.transaction_master.value_date <= @date_to
    AND
       finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(@office_id)) 
    AND
       finance.transaction_details.account_id IN (SELECT * FROM @accounts)
    ORDER BY 
        finance.transaction_master.value_date,
        finance.transaction_master.last_verified_on;


    UPDATE @retained_earnings
    SET balance = c.balance
    FROM @retained_earnings AS retained_earnings
    INNER JOIN
    (
        SELECT
            retained_earnings.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM @retained_earnings AS retained_earnings
        LEFT JOIN @retained_earnings AS c 
            ON (c.id <= retained_earnings.id)
        GROUP BY retained_earnings.id
    ) AS c
    ON retained_earnings.id = c.id;

    UPDATE @retained_earnings 
    SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM @retained_earnings AS retained_earnings 
    INNER JOIN finance.accounts
    ON retained_earnings.account_id = finance.accounts.account_id;


    UPDATE @retained_earnings SET debit = NULL WHERE debit = 0;
    UPDATE @retained_earnings SET credit = NULL WHERE credit = 0;

    INSERT INTO @result
    SELECT * FROM @retained_earnings
    ORDER BY id;

    RETURN;
END;






GO


--SELECT * FROM finance.get_retained_earnings_statement('7/16/2015', 2, 1000);

--SELECT * FROM finance.get_retained_earnings('7/16/2015', 2, 100);


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_root_account_id.sql --<--<--
-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_root_account_id.sql --<--<--
IF OBJECT_ID('finance.get_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_root_account_id;

GO

CREATE FUNCTION finance.get_root_account_id(@account_id integer, @parent bigint)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;
    DECLARE @root_account_id integer;

    SELECT @parent_account_id =  parent_account_id
    FROM finance.accounts
    WHERE finance.accounts.account_id=@account_id
    AND finance.accounts.deleted = 0;

    

    IF(@parent_account_id IS NULL)
    BEGIN
        SET @root_account_id = @account_id;
    END
    ELSE
    BEGIN
        SET @root_account_id = finance.get_root_account_id(@parent_account_id, @account_id);
    END;

    RETURN @root_account_id;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_sales_tax_account_id_by_office_id.sql --<--<--
IF OBJECT_ID('finance.get_sales_tax_account_id_by_office_id') IS NOT NULL
DROP FUNCTION finance.get_sales_tax_account_id_by_office_id;

GO

CREATE FUNCTION finance.get_sales_tax_account_id_by_office_id(@office_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT finance.tax_setups.sales_tax_account_id
	    FROM finance.tax_setups
	    WHERE finance.tax_setups.deleted = 0
	    AND finance.tax_setups.office_id = @office_id
    );
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_sales_tax_rate.sql --<--<--
IF OBJECT_ID('finance.get_sales_tax_rate') IS NOT NULL
DROP FUNCTION finance.get_sales_tax_rate;

GO

CREATE FUNCTION finance.get_sales_tax_rate(@office_id integer)
RETURNS numeric(30, 6)
AS
BEGIN
	RETURN
	(
		SELECT 
			finance.tax_setups.sales_tax_rate
		FROM finance.tax_setups
		WHERE finance.tax_setups.office_id = @office_id
	);
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_second_root_account_id.sql --<--<--
-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_second_root_account_id.sql --<--<--
IF OBJECT_ID('finance.get_second_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_second_root_account_id;

GO

CREATE FUNCTION finance.get_second_root_account_id(@account_id integer, @parent bigint)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;
    DECLARE @root_account_id integer;

    SELECT @parent_account_id =  parent_account_id
    FROM finance.accounts
    WHERE account_id=@account_id;

    IF(@parent_account_id IS NULL)
    BEGIN
        SET @root_account_id =  @parent;
    END
    ELSE
    BEGIN
        SET @root_account_id = finance.get_second_root_account_id(@parent_account_id, @account_id);
    END;

    RETURN @root_account_id;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_transaction_code.sql --<--<--
IF OBJECT_ID('finance.get_transaction_code') IS NOT NULL
DROP FUNCTION finance.get_transaction_code;

GO
CREATE FUNCTION finance.get_transaction_code(@value_date date, @office_id integer, @user_id integer, @login_id bigint)
RETURNS national character varying(24)
AS
BEGIN
    DECLARE @ret_val national character varying(1000);  

    SET @ret_val =	CAST(finance.get_new_transaction_counter(@value_date) AS varchar(24)) + '-' + 
					CONVERT(varchar(10), @value_date, 120) + '-' + 
					CAST(@office_id AS varchar(100)) + '-' + 
					CAST(@user_id AS varchar(100)) + '-' + 
					CAST(@login_id AS varchar(100))   + '-' +  
					CONVERT(VARCHAR(10), GETUTCDATE(), 108);

    RETURN @ret_val;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_value_date.sql --<--<--
IF OBJECT_ID('finance.get_value_date') IS NOT NULL
DROP FUNCTION finance.get_value_date;

GO

CREATE FUNCTION finance.get_value_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @day_id                         bigint;
    DECLARE @completed                      bit;
    DECLARE @value_date                     date;
    DECLARE @day_operation_value_date       date;

    SELECT
        @day_id                     = finance.day_operation.day_id,
        @completed                  = finance.day_operation.completed,
        @day_operation_value_date   = finance.day_operation.value_date  
    FROM finance.day_operation
    WHERE office_id = @office_id
    AND value_date =
    (
        SELECT MAX(value_date)
        FROM finance.day_operation
        WHERE office_id = @office_id
    );

    IF(@day_id IS NOT NULL)
    BEGIN
        IF(@completed = 1)
        BEGIN
            SET @value_date  = DATEADD(day, 1, @day_operation_value_date);
        END
        ELSE
        BEGIN
            SET @value_date  = @day_operation_value_date;    
        END;
    END;

    IF(@value_date IS NULL)
    BEGIN
        --SET @value_date = GETUTCDATE() AT time zone config.get_server_timezone();
        --Todo: validate the date and time produced by the following function
        SET @value_date = CAST(SYSDATETIMEOFFSET() AS date);
    END;
    
    RETURN @value_date;
END;

GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

CREATE FUNCTION finance.get_month_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    );
END;

GO

IF OBJECT_ID('finance.get_month_start_date') IS NOT NULL
DROP FUNCTION finance.get_month_start_date;

GO

CREATE FUNCTION finance.get_month_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    );

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from 
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_quarter_end_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_end_date;

GO

CREATE FUNCTION finance.get_quarter_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 2
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_quarter_start_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date;

GO

CREATE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date))
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    )
    AND frequency_id > 2;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;

GO

IF OBJECT_ID('finance.get_fiscal_half_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_end_date;

GO

CREATE FUNCTION finance.get_fiscal_half_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 3
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_fiscal_half_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_start_date;

GO

CREATE FUNCTION finance.get_fiscal_half_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = DATEADD(day, 1, MAX(value_date)) 
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND finance.frequency_setups.office_id = @office_id
    )
    AND frequency_id > 3;

    IF(@date IS NULL)
    BEGIN
        SELECT @date = starts_from
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_fiscal_year_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_end_date;

GO

CREATE FUNCTION finance.get_fiscal_year_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
        SELECT MIN(value_date) 
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(@office_id)
        AND frequency_id > 4
        AND finance.frequency_setups.office_id = @office_id
    );
END;


GO


IF OBJECT_ID('finance.get_fiscal_year_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_start_date;

GO

CREATE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT @date = starts_from
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.office_id = @office_id;

    RETURN @date;
END;




--SELECT 1 AS office_id, finance.get_value_date(1) AS today, finance.get_month_start_date(1) AS month_start_date,finance.get_month_end_date(1) AS month_end_date, finance.get_quarter_start_date(1) AS quarter_start_date, finance.get_quarter_end_date(1) AS quarter_end_date, finance.get_fiscal_half_start_date(1) AS fiscal_half_start_date, finance.get_fiscal_half_end_date(1) AS fiscal_half_end_date, finance.get_fiscal_year_start_date(1) AS fiscal_year_start_date, finance.get_fiscal_year_end_date(1) AS fiscal_year_end_date;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_verification_status_name_by_verification_status_id.sql --<--<--
IF OBJECT_ID('finance.get_verification_status_name_by_verification_status_id') IS NOT NULL
DROP FUNCTION finance.get_verification_status_name_by_verification_status_id;

GO

CREATE FUNCTION finance.get_verification_status_name_by_verification_status_id(@verification_status_id integer)
RETURNS national character varying(500)
AS

BEGIN
    RETURN
    (
	    SELECT
	        verification_status_name
	    FROM core.verification_statuses
	    WHERE core.verification_statuses.verification_status_id = @verification_status_id
	    AND core.verification_statuses.deleted = 0
	);
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.has_child_accounts.sql --<--<--
IF OBJECT_ID('finance.has_child_accounts') IS NOT NULL
DROP FUNCTION finance.has_child_accounts;

GO

CREATE FUNCTION finance.has_child_accounts(@account_id integer)
RETURNS bit
AS
BEGIN
	DECLARE @has_child bit = 0;

    IF EXISTS(SELECT TOP 1 0 FROM finance.accounts WHERE parent_account_id=@account_id)
    BEGIN
        SET @has_child = 1;
    END;

    RETURN @has_child;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.initialize_eod_operation.sql --<--<--
IF OBJECT_ID('finance.initialize_eod_operation') IS NOT NULL
DROP PROCEDURE finance.initialize_eod_operation;

GO

CREATE PROCEDURE finance.initialize_eod_operation(@user_id integer, @office_id integer, @value_date date)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF(@value_date IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 13, 1);
    END;

    IF(account.is_admin(@user_id) = 0)
    BEGIN
        RAISERROR('Access is denied.', 13, 1);
    END;

    IF(@value_date != finance.get_value_date(@office_id))
    BEGIN
        RAISERROR('Invalid value date.', 13, 1);
    END;


    IF NOT EXISTS
    (
        SELECT * FROM finance.day_operation
        WHERE value_date=@value_date
        AND office_id = @office_id
    )
    BEGIN
        INSERT INTO finance.day_operation(office_id, value_date, started_on, started_by)
        SELECT @office_id, @value_date, GETUTCDATE(), @user_id;
    END
    ELSE    
    BEGIN
        RAISERROR('EOD operation was already initialized.', 13, 1);
    END;

    RETURN;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_cash_account_id.sql --<--<--
IF OBJECT_ID('finance.is_cash_account_id') IS NOT NULL
DROP FUNCTION finance.is_cash_account_id;

GO

CREATE FUNCTION finance.is_cash_account_id(@account_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT 1 FROM finance.accounts 
        WHERE account_master_id IN(10101)
        AND account_id=@account_id
    )
    BEGIN
        RETURN 1;
    END;
    RETURN 0;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_eod_initialized.sql --<--<--
IF OBJECT_ID('finance.is_eod_initialized') IS NOT NULL
DROP FUNCTION finance.is_eod_initialized;

GO

CREATE FUNCTION finance.is_eod_initialized(@office_id integer, @value_date date)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT * FROM finance.day_operation
        WHERE office_id = @office_id
        AND value_date = @value_date
        AND completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;




--SELECT * FROM finance.is_eod_initialized(1, '1-1-2000');

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_new_day_started.sql --<--<--
IF OBJECT_ID('finance.is_new_day_started') IS NOT NULL
DROP FUNCTION finance.is_new_day_started;

GO

CREATE FUNCTION finance.is_new_day_started(@office_id integer)
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT TOP 1 0 FROM finance.day_operation
        WHERE finance.day_operation.office_id = @office_id
        AND finance.day_operation.completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;

--SELECT * FROM finance.is_new_day_started(1);

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_normally_debit.sql --<--<--
IF OBJECT_ID('finance.is_normally_debit') IS NOT NULL
DROP FUNCTION finance.is_normally_debit;

GO

CREATE FUNCTION finance.is_normally_debit(@account_id integer)
RETURNS bit
AS

BEGIN
    RETURN
    (
	    SELECT
	        finance.account_masters.normally_debit
	    FROM  finance.accounts
	    INNER JOIN finance.account_masters
	    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
	    WHERE finance.accounts.account_id = @account_id
	    AND finance.accounts.deleted = 0
	);
END



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_periodic_inventory.sql --<--<--
IF OBJECT_ID('finance.is_periodic_inventory') IS NOT NULL
DROP FUNCTION finance.is_periodic_inventory;

GO

CREATE FUNCTION finance.is_periodic_inventory(@office_id integer)
RETURNS bit
AS
BEGIN
	--This is overriden by inventory module
    RETURN 0;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_restricted_mode.sql --<--<--
IF OBJECT_ID('finance.is_restricted_mode') IS NOT NULL
DROP FUNCTION finance.is_restricted_mode;

GO

CREATE FUNCTION finance.is_restricted_mode()
RETURNS bit
AS

BEGIN
    IF EXISTS
    (
        SELECT TOP 1 0 FROM finance.day_operation
        WHERE completed = 0
    )
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.is_transaction_restricted.sql --<--<--
IF OBJECT_ID('finance.is_transaction_restricted') IS NOT NULL
DROP FUNCTION finance.is_transaction_restricted;

GO

CREATE FUNCTION finance.is_transaction_restricted
(
    @office_id      integer
)
RETURNS bit
AS
BEGIN
    RETURN
    (
	    SELECT ~ allow_transaction_posting
	    FROM core.offices
	    WHERE office_id=@office_id
    );
END;




--SELECT * FROM finance.is_transaction_restricted(1);

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.perform_eod_operation.sql --<--<--
IF OBJECT_ID('finance.perform_eod_operation') IS NOT NULL
DROP PROCEDURE finance.perform_eod_operation;

GO

CREATE PROCEDURE finance.perform_eod_operation(@user_id integer, @login_id bigint, @office_id integer, @value_date date)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @routine            national character varying(128);
    DECLARE @routine_id         integer;
    DECLARE @sql                national character varying(1000);
    DECLARE @is_error           bit= 0;
    DECLARE @notice             national character varying(1000);
    DECLARE @office_code        national character varying(50);
    DECLARE @completed          bit;
    DECLARE @completed_on       DATETIMEOFFSET;
    DECLARE @counter            integer = 0;
    DECLARE @total_rows         integer = 0;

    DECLARE @this               TABLE
    (
        routine_id              integer,
        routine_name            national character varying(128)
    );

    BEGIN TRY
        DECLARE @tran_count int = @@TRANCOUNT;
        
        IF(@tran_count= 0)
        BEGIN
            BEGIN TRANSACTION
        END;
        
        IF(@value_date IS NULL)
        BEGIN
            RAISERROR('Invalid date.', 13, 1);
        END;

        IF(account.is_admin(@user_id) = 0)
        BEGIN
            RAISERROR('Access is denied.', 13, 1);
        END;

        IF(@value_date != finance.get_value_date(@office_id))
        BEGIN
            RAISERROR('Invalid value date.', 13, 1);
        END;

        SELECT 
            @completed      = finance.day_operation.completed,
            @completed_on   = finance.day_operation.completed_on
        FROM finance.day_operation
        WHERE value_date=@value_date 
        AND office_id = @office_id;

        IF(@completed IS NULL)
        BEGIN
            RAISERROR('Invalid value date.', 13, 1);
        END
        ELSE
        BEGIN    
            IF(@completed = 1 OR @completed_on IS NOT NULL)
            BEGIN
                RAISERROR('End of day operation was already performed.', 13, 1);
                SET @is_error        = 1;
            END;
        END;

        IF EXISTS
        (
            SELECT * FROM finance.transaction_master
            WHERE value_date < @value_date
            AND verification_status_id = 0
        )
        BEGIN
            RAISERROR('Past dated transactions in verification queue.', 13, 1);
            SET @is_error        = 1;
        END;

        IF EXISTS
        (
            SELECT * FROM finance.transaction_master
            WHERE value_date = @value_date
            AND verification_status_id = 0
        )
        BEGIN
            RAISERROR('Please verify transactions before performing end of day operation.', 13, 1);
            SET @is_error        = 1;
        END;
        
        IF(@is_error = 0)
        BEGIN
            INSERT INTO @this
            SELECT routine_id, routine_name 
            FROM finance.routines 
            WHERE status = 1
            ORDER BY "order" ASC;

            SET @office_code        = core.get_office_code_by_office_id(@office_id);
            SET @notice             = 'EOD started.';
            PRINT @notice;

            SELECT @total_rows = MAX(routine_id) FROM @this;

            WHILE @counter <= @total_rows
            BEGIN
                SELECT TOP 1 
                    @routine_id = routine_id,
                    @routine = LTRIM(RTRIM(routine_name))
                FROM @this
                WHERE routine_id >= @counter
                ORDER BY routine_id;

                IF(@routine_id IS NOT NULL)
                BEGIN
                    SET @counter=@routine_id +1;        
                END
                ELSE
                BEGIN
                    BREAK;
                END;

                SET @sql                = FORMATMESSAGE('EXECUTE %s @user_id, @login_id, @office_id, @value_date;', @routine);
                PRINT @sql;
                SET @notice             = 'Performing ' + @routine + '.';
                PRINT @notice;

                EXECUTE @routine @user_id, @login_id, @office_id, @value_date;

                SET @notice             = 'Completed  ' + @routine + '.';
                PRINT @notice;
                
                WAITFOR DELAY '00:00:02';
            END;




            UPDATE finance.day_operation SET 
                completed_on = GETUTCDATE(), 
                completed_by = @user_id,
                completed = 1
            WHERE value_date=@value_date
            AND office_id = @office_id;

            SET @notice             = 'EOD of ' + @office_code + ' for ' + CAST(@value_date AS varchar(24)) + ' completed without errors.';
            PRINT @notice;

            SET @notice             = 'OK';
            PRINT @notice;

            SELECT 1;
        END;

        IF(@tran_count = 0)
        BEGIN
            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        IF(XACT_STATE() <> 0 AND @tran_count = 0) 
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @ErrorMessage national character varying(4000)  = ERROR_MESSAGE();
        DECLARE @ErrorSeverity int                              = ERROR_SEVERITY();
        DECLARE @ErrorState int                                 = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

GO


--UPDATE finance.day_operation
--SET completed = 0, completed_by = NULL, completed_on = NULL;

--EXECUTE finance.perform_eod_operation 1, 1, 1, '1/2/2017';

--ROLLBACK TRANSACTION


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.reconcile_account.sql --<--<--
IF OBJECT_ID('finance.reconcile_account') IS NOT NULL
DROP PROCEDURE finance.reconcile_account;

GO

CREATE PROCEDURE finance.reconcile_account
(
    @transaction_detail_id              bigint,
	@user_id							integer,
    @new_book_date                      date, 
    @reconciliation_memo                text
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    DECLARE @transaction_master_id      bigint;

	BEGIN TRY
		DECLARE @tran_count int = @@TRANCOUNT;
		
		IF(@tran_count= 0)
		BEGIN
			BEGIN TRANSACTION
		END;

		SELECT @transaction_master_id = finance.transaction_details.transaction_master_id 
		FROM finance.transaction_details
		WHERE finance.transaction_details.transaction_detail_id = @transaction_detail_id;

		UPDATE finance.transaction_master
		SET 
			book_date				= @new_book_date,
			audit_user_id			= @user_id,
			audit_ts				= GETUTCDATE()
		WHERE finance.transaction_master.transaction_master_id = @transaction_master_id;


		UPDATE finance.transaction_details
		SET
			book_date               = @new_book_date,
			reconciliation_memo     = @reconciliation_memo,
			audit_user_id			= @user_id,
			audit_ts				= GETUTCDATE()
		WHERE finance.transaction_details.transaction_master_id = @transaction_master_id;    
		IF(@tran_count = 0)
		BEGIN
			COMMIT TRANSACTION;
		END;
	END TRY
	BEGIN CATCH
		IF(XACT_STATE() <> 0 AND @tran_count = 0) 
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrorMessage national character varying(4000)	= ERROR_MESSAGE();
		DECLARE @ErrorSeverity int								= ERROR_SEVERITY();
		DECLARE @ErrorState int									= ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH;
END

GO

--EXECUTE finance.reconcile_account 1, 1, '1-1-2000', 'test';


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.verify_transaction.sql --<--<--
IF OBJECT_ID('finance.verify_transaction') IS NOT NULL
DROP PROCEDURE finance.verify_transaction;

GO

CREATE PROCEDURE finance.verify_transaction
(
    @transaction_master_id                  bigint,
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @verification_status_id                 smallint,
    @reason                                 national character varying(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @transaction_posted_by          integer;
    DECLARE @book                           national character varying(50);
    DECLARE @can_verify                     bit;
    DECLARE @verification_limit             numeric(30, 6);
    DECLARE @can_self_verify                bit;
    DECLARE @self_verification_limit        numeric(30, 6);
    DECLARE @posted_amount                  numeric(30, 6);
    DECLARE @has_policy                     bit= 0;
    DECLARE @journal_date                   date;
    DECLARE @journal_office_id              integer;
    DECLARE @cascading_tran_id              bigint;

    SELECT
        @book                   = finance.transaction_master.book,
        @journal_date           = finance.transaction_master.value_date,
        @journal_office_id      = finance.transaction_master.office_id,
        @transaction_posted_by  = finance.transaction_master.user_id          
    FROM
    finance.transaction_master
    WHERE finance.transaction_master.transaction_master_id=@transaction_master_id
    AND finance.transaction_master.deleted = 0;


    IF(@journal_office_id <> @office_id)
    BEGIN
        RAISERROR('Access is denied. You cannot verify a transaction of another office.', 13, 1);
    END;
        
    SELECT @posted_amount = SUM(amount_in_local_currency)
    FROM finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = @transaction_master_id
    AND finance.transaction_details.tran_type='Cr';


    SELECT
        @has_policy                 = 1,
        @can_verify                 = can_verify,
        @verification_limit         = verification_limit,
        @can_self_verify            = can_self_verify,
        @self_verification_limit    = self_verification_limit
    FROM finance.journal_verification_policy
    WHERE finance.journal_verification_policy.user_id=@user_id
    AND finance.journal_verification_policy.office_id = @office_id
    AND finance.journal_verification_policy.is_active= 1
    AND GETUTCDATE() >= effective_from
    AND GETUTCDATE() <= ends_on
    AND finance.journal_verification_policy.deleted = 0;

    IF(@can_self_verify = 0 AND @user_id = @transaction_posted_by)
    BEGIN
        SET @can_verify = 0;
    END;

    IF(@has_policy = 1)
    BEGIN
        IF(@can_verify = 1)
        BEGIN
        
            SELECT @cascading_tran_id = cascading_tran_id
            FROM finance.transaction_master
            WHERE finance.transaction_master.transaction_master_id=@transaction_master_id
            AND finance.transaction_master.deleted = 0;
            
            UPDATE finance.transaction_master
            SET 
                last_verified_on = GETUTCDATE(),
                verified_by_user_id=@user_id,
                verification_status_id=@verification_status_id,
                verification_reason=@reason
            WHERE
                finance.transaction_master.transaction_master_id=@transaction_master_id
            OR 
                finance.transaction_master.cascading_tran_id =@transaction_master_id
            OR
            finance.transaction_master.transaction_master_id = @cascading_tran_id;


            IF(COALESCE(@cascading_tran_id, 0) = 0)
            BEGIN
                SELECT @cascading_tran_id = transaction_master_id
                FROM finance.transaction_master
                WHERE finance.transaction_master.cascading_tran_id=@transaction_master_id
                AND finance.transaction_master.deleted = 0;
            END;
            
            SELECT COALESCE(@cascading_tran_id, 0);
            RETURN;
        END
        ELSE
        BEGIN
            RAISERROR('Please ask someone else to verify your transaction.', 13, 1);
        END;
    END
    ELSE
    BEGIN
        RAISERROR('No verification policy found for this user.', 13, 1);
    END;

    SELECT 0;
    RETURN;
END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.create_payment_card.sql --<--<--
IF OBJECT_ID('finance.create_payment_card') IS NOT NULL
DROP PROCEDURE finance.create_payment_card;

GO

CREATE PROCEDURE finance.create_payment_card
(
    @payment_card_code      national character varying(12),
    @payment_card_name      national character varying(100),
    @card_type_id           integer
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT * FROM finance.payment_cards
        WHERE payment_card_code = @payment_card_code
    )
    BEGIN
        INSERT INTO finance.payment_cards(payment_card_code, payment_card_name, card_type_id)
        SELECT @payment_card_code, @payment_card_name, @card_type_id;
    END
    ELSE
    BEGIN
        UPDATE finance.payment_cards
        SET 
            payment_card_code =     @payment_card_code, 
            payment_card_name =     @payment_card_name,
            card_type_id =          @card_type_id
        WHERE
            payment_card_code =     @payment_card_code;
    END;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_balance_sheet.sql --<--<--
IF OBJECT_ID('finance.get_balance_sheet_assets') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet_assets;

GO

CREATE FUNCTION finance.get_balance_sheet_assets
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

	INSERT INTO @result(account_id)
	SELECT DISTINCT account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 10100 AND 10999;


    UPDATE @result 
    SET previous_period = trans.previous_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

    UPDATE @result 
    SET current_period = trans.current_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

	UPDATE @result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name, 
		account_master_id = finance.accounts.account_master_id
	FROM @result AS result 
	INNER JOIN finance.accounts
	ON finance.accounts.account_id = result.account_id;

	UPDATE @result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM @result AS result 
	INNER JOIN finance.account_masters
	ON finance.account_masters.account_master_id = result.account_master_id;

	UPDATE @result
	SET 
		current_period = current_period / @factor,
		previous_period = previous_period / @factor;

	RETURN;
END

GO

--SELECT * FROM finance.get_balance_sheet_assets('3-14-2017', '1-1-2020', 1, 1, 1);

GO

IF OBJECT_ID('finance.get_balance_sheet_liabilities') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet_liabilities;

GO

CREATE FUNCTION finance.get_balance_sheet_liabilities
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

	INSERT INTO @result(account_id)
	SELECT DISTINCT account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 15000 AND 15999
	AND finance.verified_transaction_mat_view.account_master_id NOT IN(15300, 15400); --EXCLUDE RETAINED EARNINGS


    UPDATE @result 
    SET previous_period = trans.previous_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

    UPDATE @result 
    SET current_period = trans.current_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

	UPDATE @result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name, 
		account_master_id = finance.accounts.account_master_id
	FROM @result AS result 
	INNER JOIN finance.accounts
	ON finance.accounts.account_id = result.account_id;

	UPDATE @result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM @result AS result 
	INNER JOIN finance.account_masters
	ON finance.account_masters.account_master_id = result.account_master_id;

	UPDATE @result
	SET 
		current_period = current_period / @factor,
		previous_period = previous_period / @factor;

	RETURN;
END

GO

--SELECT * FROM finance.get_balance_sheet_liabilities('3-14-2017', '1-1-2020', 1, 1, 1);


GO

IF OBJECT_ID('finance.get_balance_sheet') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet;

GO

CREATE FUNCTION finance.get_balance_sheet
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
	INSERT INTO @result
	SELECT * FROM finance.get_balance_sheet_assets(@previous_period, @current_period, @user_id, @office_id, @factor);

	INSERT INTO @result
	SELECT * FROM finance.get_balance_sheet_liabilities(@previous_period, @current_period, @user_id, @office_id, @factor);

	INSERT INTO @result(account_id, account_number, account_name, account_master_id, account_master_name, previous_period, current_period)
	SELECT NULL, '15300', account_master_name, 15999, account_master_name, finance.get_retained_earnings(@previous_period, @office_id, @factor), finance.get_retained_earnings(@current_period, @office_id, @factor)
	FROM finance.account_masters
	WHERE finance.account_masters.account_master_id = 15300;

	RETURN;
END;

GO

--SELECT * FROM finance.get_balance_sheet('3-14-2017', '1-1-2020', 1, 1, 1);


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_cash_flow_statement.sql --<--<--
IF OBJECT_ID('finance.get_cash_flow_statement') IS NOT NULL
DROP PROCEDURE finance.get_cash_flow_statement;

GO


CREATE PROCEDURE finance.get_cash_flow_statement
(
    @date_from                      date,
    @date_to                        date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
AS
BEGIN    
	SET ANSI_WARNINGS OFF;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @periods TABLE
	(
		id					integer IDENTITY,
		period_name			national character varying(1000),
		date_from			date,
		date_to				date
	);
	
	DECLARE @cursor					CURSOR;
	DECLARE @sql					national character varying(MAX);
	DECLARE @periods_csv			national character varying(MAX);
	DECLARE @period_name			national character varying(1000);
	DECLARE @period_from			date;
	DECLARE @period_to				date;
    DECLARE @balance                numeric(30, 6);
    DECLARE @is_periodic            bit = finance.is_periodic_inventory(@office_id);

    --We cannot divide by zero.
    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

    CREATE TABLE #cf_temp
    (
        item_id                     integer PRIMARY KEY,
        item                        text,
        account_master_id           integer,
        parent_item_id              integer REFERENCES #cf_temp(item_id),
        is_summation                bit DEFAULT(0),
        is_debit                    bit DEFAULT(0),
        is_sales                    bit DEFAULT(0),
        is_purchase                 bit DEFAULT(0)
    );

	INSERT INTO @periods(period_name, date_from, date_to)
    SELECT * FROM finance.get_periods(@date_from, @date_to)
	ORDER BY date_from;

    IF NOT EXISTS(SELECT TOP 1 0 FROM @periods)
	BEGIN
        RAISERROR('Invalid period specified.', 13, 1);
		RETURN;
    END;

    /**************************************************************************************************************************************************************************************
        CREATING PERIODS
    **************************************************************************************************************************************************************************************/
	SET @cursor = CURSOR FOR 
	SELECT period_name FROM @periods
	ORDER BY id
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @period_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 EXECUTE('ALTER TABLE #cf_temp ADD "' + @period_name + '" decimal(24, 4) DEFAULT(0);');

		 FETCH NEXT FROM @cursor INTO @period_name;
	END
	CLOSE @cursor
	DEALLOCATE @cursor

    /**************************************************************************************************************************************************************************************
        CASHFLOW TABLE STRUCTURE START
    **************************************************************************************************************************************************************************************/
    INSERT INTO #cf_temp(item_id, item, is_summation, is_debit)
    SELECT  10000,  'Cash and cash equivalents, beginning of period',   0,	1   UNION ALL    
    SELECT  20000,  'Cash flows from operating activities',             1,  0   UNION ALL    
    SELECT  30000,  'Cash flows from investing activities',             1,  0   UNION ALL
    SELECT  40000,  'Cash flows from financing acticities',             1,  0   UNION ALL    
    SELECT  50000,  'Net increase in cash and cash equivalents',        0,  0   UNION ALL    
    SELECT  60000,  'Cash and cash equivalents, end of period',         0,  1;    

    INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, is_sales, is_purchase)
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 20000,  is_debit,   is_sales,   is_purchase FROM finance.cash_flow_headings WHERE cash_flow_heading_type = 'O' UNION ALL
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 30000,  is_debit,   is_sales,   is_purchase FROM finance.cash_flow_headings WHERE cash_flow_heading_type = 'I' UNION ALL 
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 40000,  is_debit,   is_sales,   is_purchase FROM finance.cash_flow_headings WHERE cash_flow_heading_type = 'F';

    INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, account_master_id)
    SELECT finance.account_masters.account_master_id + 50000, finance.account_masters.account_master_name,  finance.cash_flow_setup.cash_flow_heading_id, finance.cash_flow_headings.is_debit, finance.account_masters.account_master_id
    FROM finance.cash_flow_setup
    INNER JOIN finance.account_masters
    ON finance.cash_flow_setup.account_master_id = finance.account_masters.account_master_id
    INNER JOIN finance.cash_flow_headings
    ON finance.cash_flow_setup.cash_flow_heading_id = finance.cash_flow_headings.cash_flow_heading_id;

    /**************************************************************************************************************************************************************************************
        CASHFLOW TABLE STRUCTURE END
    **************************************************************************************************************************************************************************************/


    /**************************************************************************************************************************************************************************************
        ITERATING THROUGH PERIODS TO UPDATE TRANSACTION BALANCES
    **************************************************************************************************************************************************************************************/
	SET @cursor = CURSOR FOR 
	SELECT period_name, date_from, date_to FROM @periods
	ORDER BY id
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @period_name, @period_from, @period_to
	WHILE @@FETCH_STATUS = 0
	BEGIN
        --
        --
        --Opening cash balance.
        --
        --
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"=
            (
                SELECT
                SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
                SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
            FROM finance.verified_cash_transaction_mat_view
            WHERE account_master_id IN(10101, 10102) 
            AND value_date <''' + CAST(@period_from AS varchar) +
            ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar) + '))
            )
        WHERE #cf_temp.item_id = 10000;';

		--PRINT @sql;
        EXECUTE(@sql);

        --
        --
        --Updating debit balances of mapped account master heads.
        --
        --
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"=trans.total_amount
        FROM
        (
            SELECT finance.verified_cash_transaction_mat_view.account_master_id,
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book NOT IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'', ''Purchase.Direct'', ''Purchase.Receipt'')
        AND NOT account_master_id IN(10101, 10102) 
        AND value_date >=''' + CAST(@period_from AS varchar) + ''' AND value_date <=''' + CAST(@period_to AS varchar)+
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar) + '))
        GROUP BY finance.verified_cash_transaction_mat_view.account_master_id
        ) AS trans
        WHERE trans.account_master_id = #cf_temp.account_master_id';

		--PRINT @sql;
        EXECUTE(@sql);

        --
        --
        --Updating cash paid to suppliers.
        --
        --
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"=
        
        (
            SELECT
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) 
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book IN (''Purchase.Direct'', ''Purchase.Receipt'', ''Purchase.Payment'')
        AND NOT account_master_id IN(10101, 10102) 
        AND value_date >=''' + CAST(@period_from AS varchar) + ''' AND value_date <=''' + CAST(@period_to AS varchar) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar) + '))
        )
        WHERE #cf_temp.is_purchase = 1;';

		--PRINT @sql;
        EXECUTE(@sql);

        --
        --
        --Updating cash received from customers.
        --
        --
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"=
        
        (
            SELECT
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) 
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'')
        AND account_master_id IN(10101, 10102) 
        AND value_date >=''' + CAST(@period_from AS varchar) + ''' AND value_date <=''' + CAST(@period_to AS varchar) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar) + '))
        )
        WHERE #cf_temp.is_sales = 1;';

		--PRINT @sql;
        EXECUTE(@sql);

        --Closing cash balance.
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"
        =
        (
            SELECT
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_cash_transaction_mat_view
        WHERE account_master_id IN(10101, 10102) 
        AND value_date <''' + CAST(@period_to AS varchar) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar) + '))
        ) 
        WHERE #cf_temp.item_id = 60000;';

		--PRINT @sql;
        EXECUTE(@sql);

        --Reversing to debit balance for associated headings.
        SET @sql = 'UPDATE #cf_temp SET "' + @period_name + '"="' + @period_name + '"*-1 WHERE is_debit=1;';

		--PRINT @sql;
        EXECUTE(@sql);
		FETCH NEXT FROM @cursor INTO @period_name, @period_from, @period_to;
	END
	CLOSE @cursor;
	DEALLOCATE @cursor;



    --Updating periodic balances on parent item by the sum of their respective child balances.
    SET @sql = 'UPDATE #cf_temp SET ';

	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"=#cf_temp."' + period_name + '" + "trans"."' + period_name + '"'   FROM @periods;

	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + ' FROM  (
        SELECT parent_item_id, ';

	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM("' + period_name + '") AS "' + period_name + '"'   FROM @periods;

        SET @sql = @sql + @periods_csv;
         SET @sql = @sql + 'FROM #cf_temp
        GROUP BY parent_item_id
    ) 
    AS trans
        WHERE trans.parent_item_id = #cf_temp.item_id
        AND #cf_temp.item_id NOT IN (10000, 60000);';

	--PRINT @sql;
    EXECUTE(@sql);


	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = "trans"."' + period_name + '"' FROM @periods;

    SET @sql = 'UPDATE #cf_temp SET ';
	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + ' FROM 
    (
        SELECT
            #cf_temp.parent_item_id,';
	
	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM(CASE is_debit WHEN 1 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'  FROM @periods;
	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + '
         FROM #cf_temp
         GROUP BY #cf_temp.parent_item_id
    ) 
    AS trans
    WHERE #cf_temp.item_id = trans.parent_item_id
    AND #cf_temp.parent_item_id IS NULL;';

	--PRINT @sql;
    EXECUTE(@sql);


    --Dividing by the factor.
	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = "' + period_name + '" / ' + CAST(@factor AS varchar) + ''  FROM @periods;

    SET @sql = 'UPDATE #cf_temp SET ';
	SET @sql = @sql + @periods_csv;

	--PRINT @sql;
    EXECUTE(@sql);


    --Converting 0's to NULLS.
	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'   FROM @periods;

    SET @sql = 'UPDATE #cf_temp SET ';
	SET @sql = @sql + @periods_csv;

	--PRINT @sql;
    EXECUTE(@sql);

    SET @sql = 'SELECT item, ';
	SET @periods_csv = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"'   FROM @periods;
    SET @sql = @sql + @periods_csv;

    SET @sql = @sql + ', is_summation FROM #cf_temp
        WHERE account_master_id IS NULL
        ORDER BY item_id;';

	--PRINT @sql;
    EXECUTE(@sql);

	SET ANSI_WARNINGS ON;
END

GO


--EXECUTE finance.get_cash_flow_statement '1-1-2000','1-1-2020', 1, 1, 1;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_net_profit.sql --<--<--
-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_net_profit.sql --<--<--
IF OBJECT_ID('finance.get_net_profit') IS NOT NULL
DROP FUNCTION finance.get_net_profit;

GO

CREATE FUNCTION finance.get_net_profit
(
    @date_from                      date,
    @date_to                        date,
    @office_id                      integer,
    @factor                         integer,
    @no_provison                    bit
)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @incomes                numeric(30, 6) = 0;
    DECLARE @expenses               numeric(30, 6) = 0;
    DECLARE @profit_before_tax      numeric(30, 6) = 0;
    DECLARE @tax_paid               numeric(30, 6) = 0;
    DECLARE @tax_provison           numeric(30, 6) = 0;

    SELECT @incomes = SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id >=20100
    AND account_master_id <= 20350;
    
    SELECT @expenses = SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id >=20400
    AND account_master_id <= 20701;
    
    SELECT @tax_paid = SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id =20800;
    
    SET @profit_before_tax = COALESCE(@incomes, 0) - COALESCE(@expenses, 0);

    IF(@no_provison = 1)
    BEGIN
        RETURN (@profit_before_tax - COALESCE(@tax_paid, 0)) / @factor;
    END;
    
    SET @tax_provison      = finance.get_income_tax_provison_amount(@office_id, @profit_before_tax, COALESCE(@tax_paid, 0));
    
    RETURN (@profit_before_tax - (COALESCE(@tax_provison, 0) + COALESCE(@tax_paid, 0))) / @factor;
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_profit_and_loss_statement.sql --<--<--
IF OBJECT_ID('finance.get_profit_and_loss_statement') IS NOT NULL
DROP PROCEDURE finance.get_profit_and_loss_statement;

GO

CREATE PROCEDURE finance.get_profit_and_loss_statement
(
    @date_from                      date,
    @date_to                        date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer,
    @compact                        bit = 0
)
AS
BEGIN    
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @periods TABLE
	(
		id					integer IDENTITY,
		period_name			national character varying(1000),
		date_from			date,
		date_to				date
	);
	
	DECLARE @cursor					CURSOR;
	DECLARE @sql					national character varying(MAX);
	DECLARE @periods_csv			national character varying(MAX);
	DECLARE @period_name			national character varying(1000);
	DECLARE @period_from			date;
	DECLARE @period_to				date;
    DECLARE @balance                numeric(30, 6);
    DECLARE @is_periodic            bit = inventory.is_periodic_inventory(@office_id);
	DECLARE @profit					numeric(30, 6);

    CREATE TABLE #pl_temp
    (
        item_id                     integer PRIMARY KEY,
        item                        text,
        account_id                  integer,
        parent_item_id              integer REFERENCES #pl_temp(item_id),
        is_profit                   bit DEFAULT(0),
        is_summation                bit DEFAULT(0),
        is_debit                    bit DEFAULT(0),
        amount                      decimal(24, 4) DEFAULT(0)
    );

    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

	INSERT INTO @periods(period_name, date_from, date_to)
    SELECT * FROM finance.get_periods(@date_from, @date_to)
	ORDER BY date_from;

    IF NOT EXISTS(SELECT TOP 1 0 FROM @periods)
	BEGIN
        RAISERROR('Invalid period specified.', 13, 1);
		RETURN;
    END;

	SET @cursor = CURSOR FOR 
	SELECT period_name FROM @periods
	ORDER BY id
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @period_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 EXECUTE('ALTER TABLE #pl_temp ADD "' + @period_name + '" decimal(24, 4) DEFAULT(0);');

		 FETCH NEXT FROM @cursor INTO @period_name;
	END
	CLOSE @cursor;
	DEALLOCATE @cursor;


    --PL structure setup start
    INSERT INTO #pl_temp(item_id, item, is_summation, parent_item_id)
    SELECT 1000,   'Revenue',                      1,   NULL	UNION ALL
    SELECT 2000,   'Cost of Sales',                1,   NULL	UNION ALL
    SELECT 2001,   'Opening Stock',                0,  1000     UNION ALL
    SELECT 3000,   'Purchases',                    0,  1000     UNION ALL
    SELECT 4000,   'Closing Stock',                0,  1000     UNION ALL
    SELECT 5000,   'Direct Costs',                 1,   NULL	UNION ALL
    SELECT 6000,   'Gross Profit',                 0,  NULL		UNION ALL
    SELECT 7000,   'Operating Expenses',           1,   NULL	UNION ALL
    SELECT 8000,   'Operating Profit',             0,  NULL		UNION ALL
    SELECT 9000,   'Nonoperating Incomes',         1,   NULL	UNION ALL
    SELECT 10000,  'Financial Incomes',            1,   NULL	UNION ALL
    SELECT 11000,  'Financial Expenses',           1,   NULL	UNION ALL
    SELECT 11100,  'Interest Expenses',            1,   11000	UNION ALL
    SELECT 12000,  'Profit Before Income Taxes',   0,  NULL		UNION ALL
    SELECT 13000,  'Income Taxes',                 1,   NULL	UNION ALL
    SELECT 13001,  'Income Tax Provison',          0,  13000    UNION ALL
    SELECT 14000,  'Net Profit',                   1,   NULL;

    UPDATE #pl_temp SET is_debit = 1 WHERE item_id IN(2001, 3000, 4000);
    UPDATE #pl_temp SET is_profit = 1 WHERE item_id IN(6000,8000, 12000, 14000);
    
    INSERT INTO #pl_temp(item_id, account_id, item, parent_item_id, is_debit)
    SELECT id, account_id, account_name, 1000 as parent_item_id, 0 as is_debit FROM finance.get_account_view_by_account_master_id(20100, 1000) UNION ALL--Sales Accounts
    SELECT id, account_id, account_name, 2000 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20400, 2001) UNION ALL--COGS Accounts
    SELECT id, account_id, account_name, 5000 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20500, 5000) UNION ALL--Direct Cost
    SELECT id, account_id, account_name, 7000 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20600, 7000) UNION ALL--Operating Expenses
    SELECT id, account_id, account_name, 9000 as parent_item_id, 0 as is_debit FROM finance.get_account_view_by_account_master_id(20200, 9000) UNION ALL--Nonoperating Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, 0 as is_debit FROM finance.get_account_view_by_account_master_id(20300, 10000) UNION ALL--Financial Incomes
    SELECT id, account_id, account_name, 11000 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20700, 11000) UNION ALL--Financial Expenses
    SELECT id, account_id, account_name, 11100 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20701, 11100) UNION ALL--Interest Expenses
    SELECT id, account_id, account_name, 13000 as parent_item_id, 1 as is_debit FROM finance.get_account_view_by_account_master_id(20800, 13001);--Income Tax Expenses

    IF(@is_periodic = 0)
	BEGIN
        DELETE FROM #pl_temp WHERE item_id IN(2001, 3000, 4000);
    END;
    --PL structure setup end


	SET @cursor = CURSOR FOR 
	SELECT period_name, date_from, date_to FROM @periods
	ORDER BY id
	OPEN @cursor
	FETCH NEXT FROM @cursor INTO @period_name, @period_from, @period_to
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXECUTE
		(
			'UPDATE #pl_temp SET "' + @period_name + '"="trans".total_amount
			FROM
			(
				SELECT finance.verified_transaction_mat_view.account_id,
				SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
				SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
			FROM finance.verified_transaction_mat_view
			WHERE value_date >=''' + @period_from + ''' AND value_date <=''' + @period_to +
			''' AND office_id IN (SELECT * FROM core.get_office_ids(' + @office_id + '))
			GROUP BY finance.verified_transaction_mat_view.account_id
			) AS trans
			WHERE "trans".account_id = #pl_temp.account_id'
		);

        --Updating credit balances of individual GL accounts.
        EXECUTE
		(
			'UPDATE #pl_temp SET "' + @period_name + '"="trans".total_amount
			FROM
			(
				SELECT finance.verified_transaction_mat_view.account_id,
				SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
				SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
			FROM finance.verified_transaction_mat_view
			WHERE value_date >=''' + @period_from + ''' AND value_date <=''' + @period_to +
			''' AND office_id IN (SELECT * FROM core.get_office_ids(' + @office_id + '))
			GROUP BY finance.verified_transaction_mat_view.account_id
			) AS trans
			WHERE "trans".account_id = #pl_temp.account_id'
		);

        --Reversing to debit balance for expense headings.
        EXECUTE('UPDATE #pl_temp SET "' + @period_name + '"="' + @period_name + '"*-1 WHERE is_debit = 1;');

        --Getting purchase and stock balances if this is a periodic inventory system.
        --In perpetual accounting system, one would not need to include these headings 
        --because the COGS A/C would be automatically updated on each transaction.
        IF(@is_periodic = 1)
		BEGIN
			SET @sql = 'UPDATE #pl_temp 
				SET "' + @period_name + '"=transactions.get_closing_stock(''' + CAST(DATEADD(DAY, -1, @period_from) AS varchar) +  ''', ' + @office_id + ') 
				WHERE item_id=2001;'
 
            EXECUTE(@sql);

            EXECUTE
			(
				'UPDATE #pl_temp 
				SET "' + @period_name + '"=transactions.get_purchase(''' + @period_from +  ''', ''' + @period_to + ''', ' + @office_id + ') *-1 
				WHERE item_id=3000;'
			);

            EXECUTE
			(			
				'UPDATE #pl_temp 
				SET "' + @period_name + '"=transactions.get_closing_stock(''' + @period_from +  ''', ' + @office_id + ') 
				WHERE item_id=4000;'
			);
        END;

		FETCH NEXT FROM @cursor INTO @period_name, @period_from, @period_to;
	END
	CLOSE @cursor;
	DEALLOCATE @cursor;


    --Updating the column "amount" on each row by the sum of all periods.
	SELECT @periods_csv = COALESCE(@periods_csv + '+' , '') + '"' + period_name + '"' FROM @periods;
    EXECUTE('UPDATE #pl_temp SET amount = ' + @periods_csv + ';');

	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;

    --Updating amount and periodic balances on parent item by the sum of their respective child balances.
    SET @sql =  'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv + 
    ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, ';

	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM("' + period_name + '") AS "' + period_name + '"' FROM @periods;
	SET @sql = @sql + @periods_csv;

	SET @sql = @sql +  '
         FROM #pl_temp
        GROUP BY parent_item_id
    ) 
    AS trans
        WHERE "trans".parent_item_id = #pl_temp.item_id;'

	EXECUTE(@sql);

    --Updating Gross Profit.
    --Gross Profit = Revenue - (Cost of Sales + Direct Costs)
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;

    SET @sql = 'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv;
	SET @sql = @sql + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 1000 THEN amount ELSE amount * -1 END) AS amount, ';
	
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM(CASE item_id WHEN 1000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"' FROM @periods;
	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + '
         FROM #pl_temp
         WHERE item_id IN
         (
             1000,2000,5000
         )
    ) 
    AS trans
    WHERE item_id = 6000;'

    EXECUTE(@sql);


    --Updating Operating Profit.
    --Operating Profit = Gross Profit - Operating Expenses
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;
    SET @sql = 'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv
    + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 6000 THEN amount ELSE amount * -1 END) AS amount, ';

	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM(CASE item_id WHEN 6000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"' FROM @periods;

	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + '
         FROM #pl_temp
         WHERE item_id IN
         (
             6000, 7000
         )
    ) 
    AS trans
    WHERE item_id = 8000;'


    EXECUTE(@sql);

    --Updating Profit Before Income Taxes.
    --Profit Before Income Taxes = Operating Profit + Nonoperating Incomes + Financial Incomes - Financial Expenses
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;
    
	SET @sql = 'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv 
    + ' FROM 
    (
        SELECT
        SUM(CASE WHEN item_id IN(11000, 11100) THEN amount *-1 ELSE amount END) AS amount, ';
	
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM(CASE WHEN item_id IN(11000, 11100)  THEN "' + period_name + '" *-1 ELSE "' + period_name + '" END) AS "' + period_name + '"' FROM @periods;
	SET @sql = @sql + @periods_csv;

    SET @sql = @sql + '
         FROM #pl_temp
         WHERE item_id IN
         (
             8000, 9000, 10000, 11000, 11100
         )
    ) 
    AS trans
    WHERE item_id = 12000;';

    EXECUTE(@sql);

    --Updating Income Tax Provison.
    --Income Tax Provison = Profit Before Income Taxes * Income Tax Rate - Paid Income Taxes
	/******
		UPDATE pl_temp 
		SET 
			amount = finance.get_income_tax_provison_amount(1,-5300.000000,(SELECT amount FROM pl_temp WHERE item_id = 13000)),
			"Jul-Aug"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Jul-Aug" FROM pl_temp WHERE item_id = 13000)),
			"Aug-Sep"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Aug-Sep" FROM pl_temp WHERE item_id = 13000)),
			"Sep-Oc"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Sep-Oc" FROM pl_temp WHERE item_id = 13000)),
			"Oct-Nov"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Oct-Nov" FROM pl_temp WHERE item_id = 13000)),
			"Nov-Dec"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Nov-Dec" FROM pl_temp WHERE item_id = 13000)),
			"Dec-Jan"=finance.get_income_tax_provison_amount(1,-5300.000000, (SELECT "Dec-Jan" FROM pl_temp WHERE item_id = 13000)),
			"Jan-Feb"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Jan-Feb" FROM pl_temp WHERE item_id = 13000)),
			"Feb-Mar"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Feb-Mar" FROM pl_temp WHERE item_id = 13000)),
			"Mar-Apr"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Mar-Apr" FROM pl_temp WHERE item_id = 13000)),
			"Apr-May"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Apr-May" FROM pl_temp WHERE item_id = 13000)),
			"May-Jun"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "May-Jun" FROM pl_temp WHERE item_id = 13000)),
			"Jun-Jul"=finance.get_income_tax_provison_amount(1,0.000000, (SELECT "Jun-Jul" FROM pl_temp WHERE item_id = 13000)) 
		WHERE item_id = 13001;
	******/

    SELECT @profit = COALESCE(amount, 0) FROM #pl_temp WHERE item_id = 12000;

    
    SET @sql = 'UPDATE #pl_temp SET amount = finance.get_income_tax_provison_amount(' + CAST(@office_id AS varchar) + ',' + CAST(@profit AS varchar) + ',(SELECT amount FROM #pl_temp WHERE item_id = 13000)), ';
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = finance.get_income_tax_provison_amount(1, ' + CAST(@profit AS varchar)
					+ ', (SELECT "' + period_name + '" FROM #pl_temp WHERE item_id = 13000))'  FROM @periods;

    SET @sql = @sql + @periods_csv;
	SET @sql = @sql + ' WHERE item_id = 13001;'

    EXECUTE(@sql);

    --Updating amount and periodic balances on parent item by the sum of their respective child balances, once again to add the Income Tax Provison to Income Tax Expenses.
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;
    SET @sql = 'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv
    + ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, ';
	
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM("' + period_name + '") AS "' + period_name + '"' FROM @periods;
	SET @sql = @sql + @periods_csv;
    SET @sql = @sql + '
         FROM #pl_temp
        GROUP BY parent_item_id
    ) 
    AS trans
        WHERE "trans".parent_item_id = #pl_temp.item_id;';

    EXECUTE(@sql);


    --Updating Net Profit.
    --Net Profit = Profit Before Income Taxes - Income Tax Expenses
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"= "trans"."' + period_name + '"' FROM @periods;
    SET @sql = 'UPDATE #pl_temp SET amount = "trans".amount, ' + @periods_csv
    + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 13000 THEN amount *-1 ELSE amount END) AS amount, ';

	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + 'SUM(CASE item_id WHEN 13000 THEN "' + period_name + '" *-1 ELSE "' + period_name + '" END) AS "' + period_name + '"' FROM @periods;
    SET @sql = @sql + @periods_csv;

    SET @sql = @sql + '
         FROM #pl_temp
         WHERE item_id IN
         (
             12000, 13000
         )
    ) 
    AS trans
    WHERE item_id = 14000;';

    EXECUTE(@sql);

    --Removing ledgers having zero balances
    DELETE FROM #pl_temp
    WHERE COALESCE(amount, 0) = 0
    AND account_id IS NOT NULL;


    --Dividing by the factor.
    SET @sql = 'UPDATE #pl_temp SET amount = amount /' + CAST(@factor AS varchar) + ',' 
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = "' + period_name + '" / ' + CAST(@factor AS varchar) FROM @periods;
	SET @sql = @sql + @periods_csv + ';';

    EXECUTE(@sql);


    --Converting 0's to NULLS.
    SET @sql = 'UPDATE #pl_temp SET amount = CASE WHEN amount = 0 THEN NULL ELSE amount END,';
	SET @periods_csv  = NULL;
	SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '" = CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'  FROM @periods;
	SET @sql = @sql + @periods_csv;

    EXECUTE(@sql);


    IF(@compact = 1)
	BEGIN
        SELECT item, amount, is_profit, is_summation
        FROM #pl_temp
        ORDER BY item_id;
	END
    ELSE
	BEGIN
		SET @periods_csv  = NULL;
		SELECT @periods_csv = COALESCE(@periods_csv + ',' , '') + '"' + period_name + '"'  FROM @periods;
		SET @sql = 'SELECT item, amount,'
            + @periods_csv +
            ', is_profit, is_summation FROM #pl_temp
            ORDER BY item_id';
		EXECUTE(@sql);
    END;
END

GO

--EXECUTE finance.get_profit_and_loss_statement '1-1-2000', '1-1-2020', 1, 1, 1, 0;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_retained_earnings.sql --<--<--
IF OBJECT_ID('finance.get_retained_earnings') IS NOT NULL
DROP FUNCTION finance.get_retained_earnings;

GO

CREATE FUNCTION finance.get_retained_earnings
(
    @date_to                        date,
    @office_id                      integer,
    @factor                         integer
)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE     @date_from              date;
    DECLARE     @net_profit             numeric(30, 6);
    DECLARE     @paid_dividends         numeric(30, 6);

    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        SET @factor = 1;
    END;
    
    SET @date_from              = finance.get_fiscal_year_start_date(@office_id);    
    SET @net_profit             = finance.get_net_profit(@date_from, @date_to, @office_id, @factor, 1);

    SELECT 
        @paid_dividends = COALESCE(SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) / @factor, 0)        
    FROM finance.verified_transaction_mat_view
    WHERE value_date <= @date_to
    AND account_master_id BETWEEN 15300 AND 15400
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id));
    
    RETURN @net_profit - @paid_dividends;
END;


GO

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/logic/finance.get_trial_balance.sql --<--<--
IF OBJECT_ID('finance.get_trial_balance') IS NOT NULL
DROP FUNCTION finance.get_trial_balance;

GO

CREATE FUNCTION finance.get_trial_balance
(
    @date_from                      date,
    @date_to                        date,
    @user_id                        integer,
    @office_id                      integer,
    @compact                        bit,
    @factor                         numeric(30, 6),
    @change_side_when_negative      bit,
    @include_zero_balance_accounts  bit
)
RETURNS @result TABLE
(
    id                      integer,
    account_id              integer,
    account_number          national character varying(24),
    account                 national character varying(1000),
    previous_debit          numeric(30, 6),
    previous_credit         numeric(30, 6),
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    closing_debit           numeric(30, 6),
    closing_credit          numeric(30, 6)
)
AS

BEGIN
    IF(@date_from IS NULL)
    BEGIN
        SET @date_from = finance.get_fiscal_year_start_date(@office_id);
        --RAISERROR('Invalid date.', 13, 1);
    END;

    IF NOT EXISTS
    (
        SELECT 0 FROM core.offices
        WHERE office_id IN 
        (
            SELECT * FROM core.get_office_ids(@office_id)
        )
        HAVING count(DISTINCT currency_code) = 1
    )
    BEGIN
        --RAISERROR('Cannot produce trial balance of office(s) having different base currencies.', 13, 1);
        RETURN;
    END;

    DECLARE @trial_balance TABLE
    (
        id                      integer,
        account_id              integer,
        account_number national character varying(24),
        account                 national character varying(1000),
        previous_debit          numeric(30, 6),
        previous_credit         numeric(30, 6),
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        closing_debit           numeric(30, 6),
        closing_credit          numeric(30, 6),
        root_account_id         integer,
        normally_debit          bit
    );

    DECLARE @summary_trial_balance TABLE
    (
        id                      integer,
        account_id              integer,
        account_number          national character varying(24),
        account                 national character varying(1000),
        previous_debit          numeric(30, 6),
        previous_credit         numeric(30, 6),
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        closing_debit           numeric(30, 6),
        closing_credit          numeric(30, 6),
        root_account_id         integer,
        normally_debit          bit
    );

    INSERT INTO @trial_balance(account_id, previous_debit, previous_credit)    
    SELECT 
        verified_transaction_mat_view.account_id, 
        SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
        SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
    FROM finance.verified_transaction_mat_view
    WHERE value_date < @date_from
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    GROUP BY verified_transaction_mat_view.account_id;

    IF(@date_to IS NULL)
    BEGIN
        INSERT INTO @trial_balance(account_id, debit, credit)    
        SELECT 
            verified_transaction_mat_view.account_id, 
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
        FROM finance.verified_transaction_mat_view
        WHERE value_date > @date_from
        AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
        GROUP BY verified_transaction_mat_view.account_id;
    END
    ELSE
    BEGIN
        INSERT INTO @trial_balance(account_id, debit, credit)    
        SELECT 
            verified_transaction_mat_view.account_id, 
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
        FROM finance.verified_transaction_mat_view
        WHERE value_date >= @date_from AND value_date <= @date_to
        AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
        GROUP BY verified_transaction_mat_view.account_id;    
    END;

    UPDATE @trial_balance SET root_account_id = finance.get_root_account_id(account_id, 0);

        
    IF(@compact = 1)
    BEGIN
        INSERT INTO @summary_trial_balance(account_id, account_number, account, previous_debit, previous_credit, debit, credit, closing_debit, closing_credit, normally_debit)
        SELECT
            temp_trial_balance.root_account_id AS account_id,
            '' as account_number,
            '' as account,
            SUM(temp_trial_balance.previous_debit) AS previous_debit,
            SUM(temp_trial_balance.previous_credit) AS previous_credit,
            SUM(temp_trial_balance.debit) AS debit,
            SUM(temp_trial_balance.credit) as credit,
            SUM(temp_trial_balance.closing_debit) AS closing_debit,
            SUM(temp_trial_balance.closing_credit) AS closing_credit,
            temp_trial_balance.normally_debit
        FROM @trial_balance AS temp_trial_balance
        GROUP BY 
            temp_trial_balance.root_account_id,
            temp_trial_balance.normally_debit
        ORDER BY temp_trial_balance.normally_debit;
    END
    ELSE
    BEGIN
        INSERT INTO @summary_trial_balance(account_id, account_number, account, previous_debit, previous_credit, debit, credit, closing_debit, closing_credit, normally_debit)
        SELECT
            temp_trial_balance.account_id,
            '' as account_number,
            '' as account,
            SUM(temp_trial_balance.previous_debit) AS previous_debit,
            SUM(temp_trial_balance.previous_credit) AS previous_credit,
            SUM(temp_trial_balance.debit) AS debit,
            SUM(temp_trial_balance.credit) as credit,
            SUM(temp_trial_balance.closing_debit) AS closing_debit,
            SUM(temp_trial_balance.closing_credit) AS closing_credit,
            temp_trial_balance.normally_debit
        FROM @trial_balance AS temp_trial_balance
        GROUP BY 
            temp_trial_balance.account_id,
            temp_trial_balance.normally_debit
        ORDER BY temp_trial_balance.normally_debit;
    END;
    
    UPDATE @summary_trial_balance 
    SET
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name,
        normally_debit = finance.account_masters.normally_debit
    FROM @summary_trial_balance AS summary_trial_balance
    INNER JOIN finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
    ON summary_trial_balance.account_id = finance.accounts.account_id;

    UPDATE @summary_trial_balance SET 
        closing_debit = COALESCE(previous_debit, 0) + COALESCE(debit, 0),
        closing_credit = COALESCE(previous_credit, 0) + COALESCE(credit, 0);
        


     UPDATE @summary_trial_balance SET previous_debit = COALESCE(previous_debit, 0) - COALESCE(previous_credit, 0), previous_credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET previous_credit = COALESCE(previous_credit, 0) - COALESCE(previous_debit, 0), previous_debit = NULL WHERE normally_debit = 0;
 
     UPDATE @summary_trial_balance SET debit = COALESCE(debit, 0) - COALESCE(credit, 0), credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET credit = COALESCE(credit, 0) - COALESCE(debit, 0), debit = NULL WHERE normally_debit = 0;
 
     UPDATE @summary_trial_balance SET closing_debit = COALESCE(closing_debit, 0) - COALESCE(closing_credit, 0), closing_credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET closing_credit = COALESCE(closing_credit, 0) - COALESCE(closing_debit, 0), closing_debit = NULL WHERE normally_debit = 0;


    IF(@include_zero_balance_accounts = 0)
    BEGIN
        DELETE FROM @summary_trial_balance WHERE COALESCE(closing_debit, 0) + COALESCE(closing_credit, 0) = 0;
    END;
    
    IF(@factor > 0)
    BEGIN
        UPDATE @summary_trial_balance SET previous_debit   = previous_debit/@factor;
        UPDATE @summary_trial_balance SET previous_credit  = previous_credit/@factor;
        UPDATE @summary_trial_balance SET debit            = debit/@factor;
        UPDATE @summary_trial_balance SET credit           = credit/@factor;
        UPDATE @summary_trial_balance SET closing_debit    = closing_debit/@factor;
        UPDATE @summary_trial_balance SET closing_credit   = closing_credit/@factor;
    END;

    --Remove Zeros
    UPDATE @summary_trial_balance SET previous_debit = NULL WHERE previous_debit = 0;
    UPDATE @summary_trial_balance SET previous_credit = NULL WHERE previous_credit = 0;
    UPDATE @summary_trial_balance SET debit = NULL WHERE debit = 0;
    UPDATE @summary_trial_balance SET credit = NULL WHERE credit = 0;
    UPDATE @summary_trial_balance SET closing_debit = NULL WHERE closing_debit = 0;
    UPDATE @summary_trial_balance SET closing_debit = NULL WHERE closing_credit = 0;

    IF(@change_side_when_negative = 1)
    BEGIN
        UPDATE @summary_trial_balance SET previous_debit = previous_credit * -1, previous_credit = NULL WHERE previous_credit < 0;
        UPDATE @summary_trial_balance SET previous_credit = previous_debit * -1, previous_debit = NULL WHERE previous_debit < 0;

        UPDATE @summary_trial_balance SET debit = credit * -1, credit = NULL WHERE credit < 0;
        UPDATE @summary_trial_balance SET credit = debit * -1, debit = NULL WHERE debit < 0;

        UPDATE @summary_trial_balance SET closing_debit = closing_credit * -1, closing_credit = NULL WHERE closing_credit < 0;
        UPDATE @summary_trial_balance SET closing_credit = closing_debit * -1, closing_debit = NULL WHERE closing_debit < 0;
    END;
    
    INSERT INTO @result
    SELECT
        row_number() OVER(ORDER BY normally_debit DESC, account_id) AS id,
        account_id,
        account_number,
        account,
        previous_debit,
        previous_credit,
        debit,
        credit,
        closing_debit,
        closing_credit
    FROM @summary_trial_balance;

    RETURN;
END



GO

--SELECT * FROM finance.get_trial_balance('1-1-2000', '1-1-2020', 1, 1, 1, 1, 1, 1) ORDER BY id;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.triggers/finance.check_parent_id_trigger.sql --<--<--


IF OBJECT_ID('finance.check_parent_id_trigger') IS NOT NULL
DROP TRIGGER finance.check_parent_id_trigger;

GO

CREATE TRIGGER finance.check_parent_id_trigger
ON finance.accounts 
AFTER UPDATE
AS
BEGIN
	DECLARE @account_id					bigint
	DECLARE @parent_account_id			bigint

	SELECT 
		@account_id						= account_id,
		@parent_account_id				= parent_account_id
	FROM INSERTED;

	IF (@account_id = @parent_account_id)
		RAISERROR('Account id and parent account id cannot be same', 16, 1)
	RETURN;
END;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.triggers/finance.update_transaction_meta.sql --<--<--
IF OBJECT_ID('finance.update_transaction_meta_trigger') IS NOT NULL
DROP TRIGGER finance.update_transaction_meta_trigger;

GO

CREATE TRIGGER finance.update_transaction_meta_trigger
ON finance.transaction_master
AFTER INSERT
AS
BEGIN
    DECLARE @transaction_master_id          bigint;
    DECLARE @current_transaction_counter    integer;
    DECLARE @current_transaction_code       national character varying(50);
    DECLARE @value_date                     date;
    DECLARE @office_id                      integer;
    DECLARE @user_id                        integer;
    DECLARE @login_id                       bigint;


    SELECT
        @transaction_master_id                  = transaction_master_id,
        @current_transaction_counter            = transaction_counter,
        @current_transaction_code               = transaction_code,
        @value_date                             = value_date,
        @office_id                              = office_id,
        @user_id                                = "user_id",
        @login_id                               = login_id
    FROM INSERTED;

    IF(COALESCE(@current_transaction_code, '') = '')
    BEGIN
        UPDATE finance.transaction_master
        SET transaction_code = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id)
        WHERE transaction_master_id = @transaction_master_id;
    END;

    IF(COALESCE(@current_transaction_counter, 0) = 0)
    BEGIN
        UPDATE finance.transaction_master
        SET transaction_counter = finance.get_new_transaction_counter(@value_date)
        WHERE transaction_master_id = @transaction_master_id;
    END;

END;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/03.menus/menus.sql --<--<--
DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Finance'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Finance'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.Finance';


EXECUTE core.create_app 'MixERP.Finance', 'Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/tasks/journal/entry', NULL;

EXECUTE core.create_menu 'MixERP.Finance', 'Tasks', 'Tasks', '', 'lightning', '';
EXECUTE core.create_menu 'MixERP.Finance', 'JournalEntry', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'add square', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'ExchangeRates', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'exchange', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'JournalVerification', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'VerificationPolicy', 'Verification Policy', '/dashboard/finance/tasks/verification-policy', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'AutoVerificationPolicy', 'Auto Verification Policy', '/dashboard/finance/tasks/verification-policy/auto', 'check circle', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'AccountReconciliation', 'Account Reconciliation', '/dashboard/finance/tasks/account-reconciliation', 'book', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'EODProcessing', 'EOD Processing', '/dashboard/finance/tasks/eod-processing', 'spinner', 'Tasks';
EXECUTE core.create_menu 'MixERP.Finance', 'ImportTransactions', 'Import Transactions', '/dashboard/finance/tasks/import-transactions', 'upload', 'Tasks';

EXECUTE core.create_menu 'MixERP.Finance', 'Setup', 'Setup', 'square outline', 'configure', '';
EXECUTE core.create_menu 'MixERP.Finance', 'ChartOfAccounts', 'Chart of Accounts', '/dashboard/finance/setup/chart-of-accounts', 'sitemap', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'Currencies', 'Currencies', '/dashboard/finance/setup/currencies', 'dollar', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'BankAccounts', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'university', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'CashFlowHeadings', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'book', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'CashFlowSetup', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'edit', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'CostCenters', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'closed captioning', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'CashRepositories', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'bookmark', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'FiscalYears', 'Fiscal Years', '/dashboard/finance/setup/fiscal-years', 'sitemap', 'Setup';
EXECUTE core.create_menu 'MixERP.Finance', 'FrequencySetups', 'Frequency Setups', '/dashboard/finance/setup/frequency-setups', 'sitemap', 'Setup';

EXECUTE core.create_menu 'MixERP.Finance', 'Reports', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'MixERP.Finance', 'AccountStatement', 'Account Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/AccountStatement.xml', 'file national character varying(1000) outline', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'TrialBalance', 'Trial Balance', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TrialBalance.xml', 'signal', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'TransactionSummary', 'Transaction Summary', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TransactionSummary.xml', 'signal', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'ProfitAndLossAccount', 'Profit & Loss Account', '/dashboard/finance/reports/pl-account', 'line chart', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'RetainedEarningsStatement', 'Retained Earnings Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/RetainedEarnings.xml', 'arrow circle down', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'BalanceSheet', 'Balance Sheet', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/BalanceSheet.xml', 'calculator', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'CashFlow', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'crosshairs', 'Reports';
EXECUTE core.create_menu 'MixERP.Finance', 'ExchangeRateReport', 'Exchange Rate Report', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/ExchangeRates.xml', 'options', 'Reports';

DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'MixERP.Finance',
'{*}';



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/04.default-values/01.default-values.sql --<--<--
INSERT INTO finance.frequencies(frequency_id, frequency_code, frequency_name)
SELECT 2, 'EOM', 'End of Month'                 UNION ALL
SELECT 3, 'EOQ', 'End of Quarter'               UNION ALL
SELECT 4, 'EOH', 'End of Half'                  UNION ALL
SELECT 5, 'EOY', 'End of Year';



INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name)
SELECT 1, 'BSA', 'Balance Sheet A/C' UNION ALL
SELECT 2, 'PLA', 'Profit & Loss A/C' UNION ALL
SELECT 3, 'OBS', 'Off Balance Sheet A/C';

INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, parent_account_master_id, normally_debit)
SELECT 10100, 'CRA', 'Current Assets',                      1,      1    UNION ALL
SELECT 10101, 'CAS', 'Cash A/C',                            10100,  1    UNION ALL
SELECT 10102, 'CAB', 'Bank A/C',                            10100,  1    UNION ALL
SELECT 10103, 'INV', 'Investments',                 		1,  	1    UNION ALL
SELECT 10110, 'ACR', 'Accounts Receivable',                 10100,  1    UNION ALL
SELECT 10200, 'FIA', 'Fixed Assets',                        1,      1    UNION ALL
SELECT 10201, 'PPE', 'Property, Plants, and Equipments',    1,      1    UNION ALL
SELECT 10300, 'OTA', 'Other Assets',                        1,      1    UNION ALL
SELECT 15000, 'CRL', 'Current Liabilities',                 1,      0	UNION ALL
SELECT 15001, 'CAP', 'Capital',                    			15000,  0   UNION ALL
SELECT 15010, 'ACP', 'Accounts Payable',                    15000,  0   UNION ALL
SELECT 15020, 'DEP', 'Deposit Payable',                   	15000,  0   UNION ALL
SELECT 15030, 'BBP', 'Borrowings and Bills Payable',		15000,  0   UNION ALL
SELECT 15011, 'SAP', 'Salary Payable',                      15000,  0   UNION ALL
SELECT 15100, 'LTL', 'Long-Term Liabilities',               1,      0   UNION ALL
SELECT 15200, 'SHE', 'Shareholders'' Equity',               1,      0   UNION ALL
SELECT 15300, 'RET', 'Retained Earnings',                   15200,  0   UNION ALL
SELECT 15400, 'DIP', 'Dividends Paid',                      15300,  0	UNION ALL
SELECT 15500, 'OTP', 'Other Payable',                      	15000,  0;


INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, parent_account_master_id, normally_debit)
SELECT 20100, 'REV', 'Revenue',                           2,        0   UNION ALL
SELECT 20200, 'NOI', 'Non Operating Income',              2,        0   UNION ALL
SELECT 20300, 'FII', 'Financial Incomes',                 2,        0   UNION ALL
SELECT 20301, 'DIR', 'Dividends Received',                20300,    0   UNION ALL
SELECT 20302, 'INI', 'Interest Incomes',                  2,        0   UNION ALL
SELECT 20310, 'CMR', 'Commissions Received',              2,        0   UNION ALL
SELECT 20350, 'OTI', 'Other Incomes',              		  2,        0   UNION ALL
SELECT 20400, 'COS', 'Cost of Sales',                     2,        1   UNION ALL
SELECT 20500, 'DRC', 'Direct Costs',                      2,        1   UNION ALL
SELECT 20600, 'ORX', 'Operating Expenses',                2,        1   UNION ALL
SELECT 20700, 'FIX', 'Financial Expenses',                2,        1   UNION ALL
SELECT 20701, 'INT', 'Interest Expenses',                 20700,    1   UNION ALL
SELECT 20710, 'OTE', 'Other Expenses',                 	  2,    	1 	UNION ALL
SELECT 20800, 'ITX', 'Income Tax Expenses',               2,        1;

GO

ALTER TABLE finance.accounts
ALTER column currency_code national character varying(12) NULL;

GO

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 1,     '10000', 'Assets',                                                      1,  finance.get_account_id_by_account_name('Balance Sheet A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10001', 'Current Assets',                                              1,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10100', 'Cash at Bank A/C',                                            1,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10110', 'Regular Checking Account',                                    0, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10120', 'Payroll Checking Account',                                    0, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10130', 'Savings Account',                                             0, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10140', 'Special Account',                                             0, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10101, '10200', 'Cash in Hand A/C',                                            1,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10300', 'Investments',                                                 0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10301', 'Loan & Advances',                                             0, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10310', 'Short Term Investment',                                       0, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10320', 'Other Investments',                                           0, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10321', 'Investments-Money Market',                                    0, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10322', 'Bank Deposit Contract (Fixed Deposit)',                       0, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10323', 'Investments-Certificates of Deposit',                         0, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10110, '10400', 'Accounts Receivable',                                         0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10500', 'Other Receivables',                                           0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10501', 'Purchase Return (Receivables)',                               0, finance.get_account_id_by_account_name('Other Receivables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10600', 'Loan Loss Allowances',                             1, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10601', 'Net Loan Loss Allowances',                             1, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10700', 'Inventory',                                                   1,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10720', 'Raw Materials Inventory',                                     1,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10730', 'Supplies Inventory',                                          1,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10740', 'Work in Progress Inventory',                                  1,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10750', 'Finished ods Inventory',                                    1,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10800', 'Prepaid Expenses',                                            0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10900', 'Employee Advances',                                           0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11000', 'Notes Receivable-Current',                                    0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11100', 'Prepaid Interest',                                            0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11200', 'Accrued Incomes (Assets)',                                    0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11300', 'Other Debtors',                                               0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11400', 'Other Current Assets',                                        0, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12001', 'Noncurrent Assets',                                           1,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12100', 'Furniture and Fixtures',                                      0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10201, '12200', 'Plants & Equipments',                                         0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12300', 'Rental Property',                                             0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12400', 'Vehicles',                                                    0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12500', 'Intangibles',                                                 0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12600', 'Other Depreciable Properties',                                0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12700', 'Leasehold Improvements',                                      0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12800', 'Buildings',                                                   0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12900', 'Building Improvements',                                       0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13000', 'Interior Decorations',                                        0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13100', 'Land',                                                        0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13300', 'Trade Debtors',                                               0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13400', 'Rental Debtors',                                              0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13500', 'Staff Debtors',                                               0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13600', 'Other Noncurrent Debtors',                                    0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13700', 'Other Financial Assets',                                      0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13710', 'Deposits Held',                                               0, finance.get_account_id_by_account_name('Other Financial Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13800', 'Accumulated Depreciations',                                   0, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13810', 'Accumulated Depreciation-Furniture and Fixtures',             0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13820', 'Accumulated Depreciation-Equipment',                          0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13830', 'Accumulated Depreciation-Vehicles',                           0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13840', 'Accumulated Depreciation-Other Depreciable Properties',       0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13850', 'Accumulated Depreciation-Leasehold',                          0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13860', 'Accumulated Depreciation-Buildings',                          0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13870', 'Accumulated Depreciation-Building Improvements',              0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13880', 'Accumulated Depreciation-Interior Decorations',               0, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14001', 'Other Assets',                                                1,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14100', 'Other Assets-Deposits',                                       0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14200', 'Other Assets-Organization Costs',                             0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14300', 'Other Assets-Accumulated Amortization-Organization Costs',    0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14400', 'Notes Receivable-Non-current',                                0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14500', 'Other Non-current Assets',                                    0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14600', 'Non-financial Assets',                                        0, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 1,     '20000', 'Liabilities',                                                 1,  finance.get_account_id_by_account_name('Balance Sheet A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20001', 'Current Liabilities',                                         1,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15001, '20010', 'Shareholders',                                            0, finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15010, '20100', 'Accounts Payable',                                            0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20110', 'Shipping Charge Payable',                                     0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20200', 'Accrued Expenses',                                            0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20300', 'Wages Payable',                                               0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20400', 'Deductions Payable',                                          0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20500', 'Health Insurance Payable',                                    0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20600', 'Superannuation Payable',                                      0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20700', 'Tax Payables',                                                0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20701', 'Sales Return (Payables)',                                     0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20710', 'Sales Tax Payable',                                           0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20720', 'Federal Payroll Taxes Payable',                               0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20730', 'FUTA Tax Payable',                                            0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20740', 'State Payroll Taxes Payable',                                 0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20750', 'SUTA Payable',                                                0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20760', 'Local Payroll Taxes Payable',                                 0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20770', 'Income Taxes Payable',                                        0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20780', 'Other Taxes Payable',                                         0, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20800', 'Employee Benefits Payable',                                   0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20810', 'Provision for Annual Leave',                                  0, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20820', 'Provision for Long Service Leave',                            0, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20830', 'Provision for Personal Leave',                                0, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20840', 'Provision for Health Leave',                                  0, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20900', 'Current Portion of Long-term Debt',                           0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21000', 'Advance Incomes',                                             0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21010', 'Advance Sales Income',                                        0, finance.get_account_id_by_account_name('Advance Incomes');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21020', 'Grant Received in Advance',                                   0, finance.get_account_id_by_account_name('Advance Incomes');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21100', 'Deposits from Customers',                                     0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21200', 'Other Current Liabilities',                                   0, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21210', 'Short Term Loan Payables',                                    0, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21220', 'Short Term Hire-purchase Payables',                           0, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21230', 'Short Term Lease Liability',                                  0, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21240', 'Grants Repayable',                                            0, finance.get_account_id_by_account_name('Other Current Liabilities');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21300', 'Deposits Payable',                                    		  0, finance.get_account_id_by_account_name('Current Liabilities');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21310', 'Current Deposits Payable',                                    0, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21320', 'Call Deposits Payable',                                       0, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21330', 'Recurring Deposits Payable',                                  0, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21340', 'Term Deposits Payable',                                       0, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24001', 'Noncurrent Liabilities',                                      1,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24100', 'Notes Payable',                                               0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24200', 'Land Payable',                                                0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24300', 'Equipment Payable',                                           0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24400', 'Vehicles Payable',                                            0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24500', 'Lease Liability',                                             0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24600', 'Loan Payable',                                                0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24610', 'Interest Payable',                                            0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24700', 'Hire-purchase Payable',                                       0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24800', 'Bank Loans Payable',                                          0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24900', 'Deferred Revenue',                                            0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '25000', 'Other Long-term Liabilities',                                 0, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '25010', 'Long Term Employee Benefit Provision',                        0, finance.get_account_id_by_account_name('Other Long-term Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28001', 'Equity',                                                      1,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28100', 'Stated Capital',                                              0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28110', 'Founder Capital',                                             0, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28120', 'Promoter Capital',                                            0, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28130', 'Member Capital',                                              0, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28200', 'Capital Surplus',                                             0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28210', 'Share Premium',                                               0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28220', 'Capital Redemption Reserves',                                 0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28230', 'Statutory Reserves',                                          0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28240', 'Asset Revaluation Reserves',                                  0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28250', 'Exchange Rate Fluctuation Reserves',                          0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28260', 'Capital Reserves Arising From Merger',                        0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28270', 'Capital Reserves Arising From Acuisition',                    0, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28300', 'Retained Surplus',                                            1,  finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28310', 'Accumulated Profits',                                         0, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28320', 'Accumulated Losses',                                          0, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15400, '28330', 'Dividends Declared (Common Stock)',                           0, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15400, '28340', 'Dividends Declared (Preferred Stock)',                        0, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28400', 'Treasury Stock',                                              0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28500', 'Current Year Surplus',                                        0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28600', 'General Reserves',                                            0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28700', 'Other Reserves',                                              0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28800', 'Dividends Payable (Common Stock)',                            0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28900', 'Dividends Payable (Preferred Stock)',                         0, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '30000', 'Revenues',                                                    1,  finance.get_account_id_by_account_name('Profit and Loss A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30100', 'Sales A/C',                                                  0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30200', 'Interest Income',                                            0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30300', 'Other Income',                                               0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30400', 'Finance Charge Income',                                      0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30500', 'Shipping Charges Reimbursed',                                0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30600', 'Sales Returns and Allowances',                               0, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30700', 'Purchase Discounts',                                         0, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30210', 'Late Fee Incomes',                                           0, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30220', 'Penalty Incomes',                                            0, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30230', 'Admission Fees',                                             0, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30240', 'Other Fees & Charges',                                       0, finance.get_account_id_by_account_name('Revenues');


INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '40000', 'Expenses',                                                    1,  finance.get_account_id_by_account_name('Profit and Loss A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '40100', 'Purchase A/C',                                                0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20400,  '40200', 'Cost of Goods Sold',                                         0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40205', 'Product Cost',                                               0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40210', 'Raw Material Purchases',                                     0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40215', 'Direct Labor Costs',                                         0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40220', 'Indirect Labor Costs',                                       0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40225', 'Heat and Power',                                             0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40230', 'Commissions',                                                0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40235', 'Miscellaneous Factory Costs',                                0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40240', 'Cost of Goods Sold-Salaries and Wages',                      0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40245', 'Cost of Goods Sold-Contract Labor',                          0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40250', 'Cost of Goods Sold-Freight',                                 0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40255', 'Cost of Goods Sold-Other',                                   0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40260', 'Inventory Adjustments',                                      0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40265', 'Purchase Returns and Allowances',                            0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40270', 'Sales Discounts',                                            0, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40300', 'General Purchase Expenses',                                  0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40400', 'Advertising Expenses',                                       0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40500', 'Amortization Expenses',                                      0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40600', 'Auto Expenses',                                              0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40700', 'Bad Debt Expenses',                                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '40800', 'Bank Fees',                                                  0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40900', 'Cash Over and Short',                                        0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41000', 'Charitable Contributions Expenses',                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '41100', 'Commissions and Fees Expenses',                              0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41200', 'Depreciation Expenses',                                      0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41300', 'Dues and Subscriptions Expenses',                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41400', 'Employee Benefit Expenses',                                  0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41410', 'Employee Benefit Expenses-Health Insurance',                 0, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41420', 'Employee Benefit Expenses-Pension Plans',                    0, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41430', 'Employee Benefit Expenses-Profit Sharing Plan',              0, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41440', 'Employee Benefit Expenses-Other',                            0, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41500', 'Freight Expenses',                                           0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41600', 'Gifts Expenses',                                             0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41700', 'Income Tax Expenses',                                        0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41710', 'Income Tax Expenses-Federal',                                0, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41720', 'Income Tax Expenses-State',                                  0, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41730', 'Income Tax Expenses-Local',                                  0, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41800', 'Insurance Expenses',                                         0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41810', 'Insurance Expenses-Product Liability',                       0, finance.get_account_id_by_account_name('Insurance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41820', 'Insurance Expenses-Vehicle',                                 0, finance.get_account_id_by_account_name('Insurance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20701,  '41900', 'Interest Expenses',                                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42000', 'Laundry and Dry Cleaning Expenses',                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42100', 'Legal and Professional Expenses',                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42200', 'Licenses Expenses',                                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42300', 'Loss on NSF Checks',                                         0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42400', 'Maintenance Expenses',                                       0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42500', 'Meals and Entertainment Expenses',                           0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42600', 'Office Expenses',                                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42700', 'Payroll Tax Expenses',                                       0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '42800', 'Penalties and Fines Expenses',                               0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42900', 'Other Tax Expenses',                                        0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43000', 'Postage Expenses',                                           0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43100', 'Rent or Lease Expenses',                                     0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43200', 'Repair and Maintenance Expenses',                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43210', 'Repair and Maintenance Expenses-Office',                     0, finance.get_account_id_by_account_name('Repair and Maintenance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43220', 'Repair and Maintenance Expenses-Vehicle',                    0, finance.get_account_id_by_account_name('Repair and Maintenance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43300', 'Supplies Expenses-Office',                                   0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43400', 'Telephone Expenses',                                         0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43500', 'Training Expenses',                                          0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43600', 'Travel Expenses',                                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43700', 'Salary Expenses',                                            0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43800', 'Wages Expenses',                                             0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43900', 'Utilities Expenses',                                         0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '44000', 'Other Expenses',                                             0, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '44100', 'Gain/Loss on Sale of Assets',                                0, finance.get_account_id_by_account_name('Expenses');


UPDATE finance.accounts
SET currency_code='USD';

GO

ALTER TABLE finance.accounts
ALTER column currency_code national character varying(12) NOT NULL;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.account_scrud_view.sql --<--<--
IF OBJECT_ID('finance.account_scrud_view') IS NOT NULL
DROP VIEW finance.account_scrud_view --CASCADE;

GO



CREATE VIEW finance.account_scrud_view
AS
SELECT
    finance.accounts.account_id,
    finance.account_masters.account_master_code + ' (' + finance.account_masters.account_master_name + ')' AS account_master,
    finance.accounts.account_number,
    finance.accounts.external_code,
    core.currencies.currency_code + ' ('+ core.currencies.currency_name+ ')' currency,
    finance.accounts.account_name,
    finance.accounts.description,
    finance.accounts.confidential,
    finance.accounts.is_transaction_node,
    finance.accounts.sys_type,
    finance.accounts.account_master_id,
    parent_account.account_number + ' (' + parent_account.account_name + ')' AS parent    
FROM finance.accounts
INNER JOIN finance.account_masters
ON finance.account_masters.account_master_id=finance.accounts.account_master_id
LEFT JOIN core.currencies
ON finance.accounts.currency_code = core.currencies.currency_code
LEFT JOIN finance.accounts parent_account
ON parent_account.account_id=finance.accounts.parent_account_id
WHERE finance.accounts.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.auto_verification_policy_scrud_view.sql --<--<--
IF OBJECT_ID('finance.auto_verification_policy_scrud_view') IS NOT NULL
DROP VIEW finance.auto_verification_policy_scrud_view;

GO




CREATE VIEW finance.auto_verification_policy_scrud_view
AS
SELECT
    finance.auto_verification_policy.auto_verification_policy_id,
    finance.auto_verification_policy.user_id,
    account.get_name_by_user_id(finance.auto_verification_policy.user_id) AS "user",
    finance.auto_verification_policy.office_id,
    core.get_office_name_by_office_id(finance.auto_verification_policy.office_id) AS office,
    finance.auto_verification_policy.effective_from,
    finance.auto_verification_policy.ends_on,
    finance.auto_verification_policy.is_active
FROM finance.auto_verification_policy
WHERE finance.auto_verification_policy.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.bank_account_scrud_view.sql --<--<--
IF OBJECT_ID('finance.bank_account_scrud_view') IS NOT NULL
DROP VIEW finance.bank_account_scrud_view;

GO



CREATE VIEW finance.bank_account_scrud_view
AS
SELECT 
    finance.bank_accounts.bank_account_id,
    finance.bank_accounts.account_id,
    account.users.name AS maintained_by,
    core.offices.office_code + '(' + core.offices.office_name+')' AS office_name,
    finance.bank_accounts.bank_name,
    finance.bank_accounts.bank_branch,
    finance.bank_accounts.bank_contact_number,
    finance.bank_accounts.bank_account_number,
    finance.bank_accounts.bank_account_type,
    finance.bank_accounts.relationship_officer_name
FROM finance.bank_accounts
INNER JOIN account.users
ON finance.bank_accounts.maintained_by_user_id = account.users.user_id
INNER JOIN core.offices
ON finance.bank_accounts.office_id = core.offices.office_id
WHERE finance.bank_accounts.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.cash_flow_heading_scrud_view.sql --<--<--
IF OBJECT_ID('finance.cash_flow_heading_scrud_view') IS NOT NULL
DROP VIEW finance.cash_flow_heading_scrud_view;

GO



CREATE VIEW finance.cash_flow_heading_scrud_view
AS
SELECT 
  finance.cash_flow_headings.cash_flow_heading_id, 
  finance.cash_flow_headings.cash_flow_heading_code, 
  finance.cash_flow_headings.cash_flow_heading_name, 
  finance.cash_flow_headings.cash_flow_heading_type, 
  finance.cash_flow_headings.is_debit, 
  finance.cash_flow_headings.is_sales, 
  finance.cash_flow_headings.is_purchase
FROM finance.cash_flow_headings
WHERE finance.cash_flow_headings.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.cash_flow_setup_scrud_view.sql --<--<--
IF OBJECT_ID('finance.cash_flow_setup_scrud_view') IS NOT NULL
DROP VIEW finance.cash_flow_setup_scrud_view;

GO



CREATE VIEW finance.cash_flow_setup_scrud_view
AS
SELECT 
    finance.cash_flow_setup.cash_flow_setup_id, 
    finance.cash_flow_headings.cash_flow_heading_code + '('+ finance.cash_flow_headings.cash_flow_heading_name+')' AS cash_flow_heading, 
    finance.account_masters.account_master_code + '('+ finance.account_masters.account_master_name+')' AS account_master
FROM finance.cash_flow_setup
INNER JOIN finance.cash_flow_headings
ON  finance.cash_flow_setup.cash_flow_heading_id =finance.cash_flow_headings.cash_flow_heading_id
INNER JOIN finance.account_masters
ON finance.cash_flow_setup.account_master_id = finance.account_masters.account_master_id
WHERE finance.cash_flow_setup.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.cash_repository_scrud_view.sql --<--<--
IF OBJECT_ID('finance.cash_repository_scrud_view') IS NOT NULL
DROP VIEW finance.cash_repository_scrud_view;

GO



CREATE VIEW finance.cash_repository_scrud_view
AS
SELECT
    finance.cash_repositories.cash_repository_id,
    core.offices.office_code + ' (' + core.offices.office_name + ') ' AS office,
    finance.cash_repositories.cash_repository_code,
    finance.cash_repositories.cash_repository_name,
    parent_cash_repository.cash_repository_code + ' (' + parent_cash_repository.cash_repository_name + ') ' AS parent_cash_repository,
    finance.cash_repositories.description
FROM finance.cash_repositories
INNER JOIN core.offices
ON finance.cash_repositories.office_id = core.offices.office_id
LEFT JOIN finance.cash_repositories AS parent_cash_repository
ON finance.cash_repositories.parent_cash_repository_id = parent_cash_repository.parent_cash_repository_id
WHERE finance.cash_repositories.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.cost_center_scrud_view.sql --<--<--
IF OBJECT_ID('finance.cost_center_scrud_view') IS NOT NULL
DROP VIEW finance.cost_center_scrud_view;

GO



CREATE VIEW finance.cost_center_scrud_view
AS
SELECT
    finance.cost_centers.cost_center_id,
    finance.cost_centers.cost_center_code,
    finance.cost_centers.cost_center_name
FROM finance.cost_centers
WHERE finance.cost_centers.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.fiscal_year_scrud_view.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.frequency_setup_scrud_view.sql --<--<--
IF OBJECT_ID('finance.frequency_setup_scrud_view') IS NOT NULL
DROP VIEW finance.frequency_setup_scrud_view;

GO

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
WHERE finance.frequency_setups.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.journal_verification_policy_scrud_view.sql --<--<--
IF OBJECT_ID('finance.journal_verification_policy_scrud_view') IS NOT NULL
DROP VIEW finance.journal_verification_policy_scrud_view;

GO




CREATE VIEW finance.journal_verification_policy_scrud_view
AS
SELECT
    finance.journal_verification_policy.journal_verification_policy_id,
    finance.journal_verification_policy.user_id,
    account.get_name_by_user_id(finance.journal_verification_policy.user_id) AS "user",
    finance.journal_verification_policy.office_id,
    core.get_office_name_by_office_id(finance.journal_verification_policy.office_id) AS office,
    finance.journal_verification_policy.can_verify,
    finance.journal_verification_policy.can_self_verify,
    finance.journal_verification_policy.effective_from,
    finance.journal_verification_policy.ends_on,
    finance.journal_verification_policy.is_active
FROM finance.journal_verification_policy
WHERE finance.journal_verification_policy.deleted = 0;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.merchant_fee_setup_scrud_view.sql --<--<--
IF OBJECT_ID('finance.merchant_fee_setup_scrud_view') IS NOT NULL
DROP VIEW finance.merchant_fee_setup_scrud_view --CASCADE;

GO



CREATE VIEW finance.merchant_fee_setup_scrud_view
AS
SELECT 
    finance.merchant_fee_setup.merchant_fee_setup_id,
    finance.bank_accounts.bank_name + ' (' + finance.bank_accounts.bank_account_number + ')' AS merchant_account,
    finance.payment_cards.payment_card_code + ' ( '+ finance.payment_cards.payment_card_name + ')' AS payment_card,
    finance.merchant_fee_setup.rate,
    finance.merchant_fee_setup.customer_pays_fee,
    finance.accounts.account_number + ' (' + finance.accounts.account_name + ')' As account,
    finance.merchant_fee_setup.statement_reference
FROM finance.merchant_fee_setup
INNER JOIN finance.bank_accounts
ON finance.merchant_fee_setup.merchant_account_id = finance.bank_accounts.account_id
INNER JOIN
finance.payment_cards
ON finance.merchant_fee_setup.payment_card_id = finance.payment_cards.payment_card_id
INNER JOIN
finance.accounts
ON finance.merchant_fee_setup.account_id = finance.accounts.account_id
WHERE finance.merchant_fee_setup.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.payment_card_scrud_view.sql --<--<--
IF OBJECT_ID('finance.payment_card_scrud_view') IS NOT NULL
DROP VIEW finance.payment_card_scrud_view;

GO



CREATE VIEW finance.payment_card_scrud_view
AS
SELECT 
    finance.payment_cards.payment_card_id,
    finance.payment_cards.payment_card_code,
    finance.payment_cards.payment_card_name,
    finance.card_types.card_type_code + ' (' + finance.card_types.card_type_name + ')' AS card_type
FROM finance.payment_cards
INNER JOIN finance.card_types
ON finance.payment_cards.card_type_id = finance.card_types.card_type_id
WHERE finance.payment_cards.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.account_selector_view.sql --<--<--
IF OBJECT_ID('finance.account_selector_view') IS NOT NULL
DROP VIEW finance.account_selector_view;

GO



CREATE VIEW finance.account_selector_view
AS
SELECT
    finance.accounts.account_id,
    finance.accounts.account_number AS account_code,
    finance.accounts.account_name
FROM finance.accounts
WHERE finance.accounts.deleted = 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.asset_selector_view.sql --<--<--
IF OBJECT_ID('finance.asset_selector_view') IS NOT NULL
DROP VIEW finance.asset_selector_view;

GO

CREATE VIEW finance.asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS asset_id,
    finance.account_scrud_view.account_name AS asset_name
FROM finance.account_scrud_view
WHERE account_master_id BETWEEN 10000 AND 14999;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.bank_account_selector_view.sql --<--<--
IF OBJECT_ID('finance.bank_account_selector_view') IS NOT NULL
DROP VIEW finance.bank_account_selector_view;

GO

CREATE VIEW finance.bank_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS bank_account_id,
    finance.account_scrud_view.account_name AS bank_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10102));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.cash_account_selector_view.sql --<--<--
IF OBJECT_ID('finance.cash_account_selector_view') IS NOT NULL
DROP VIEW finance.cash_account_selector_view;

GO

CREATE VIEW finance.cash_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS cash_account_id,
    finance.account_scrud_view.account_name AS cash_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10101));

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.cost_of_sale_selector_view.sql --<--<--
IF OBJECT_ID('finance.cost_of_sale_selector_view') IS NOT NULL
DROP VIEW finance.cost_of_sale_selector_view;

GO


CREATE VIEW finance.cost_of_sale_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS cost_of_sale_id,
    finance.account_scrud_view.account_name AS cost_of_sale_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20400));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.current_asset_selector_view.sql --<--<--
IF OBJECT_ID('finance.current_asset_selector_view') IS NOT NULL
DROP VIEW finance.current_asset_selector_view;

GO

CREATE VIEW finance.current_asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS current_asset_id,
    finance.account_scrud_view.account_name AS current_asset_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10100));

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.current_liability_selector_view.sql --<--<--
IF OBJECT_ID('finance.current_liability_selector_view') IS NOT NULL
DROP VIEW finance.current_liability_selector_view;

GO


CREATE VIEW finance.current_liability_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS current_liability_id,
    finance.account_scrud_view.account_name AS current_liability_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15000));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.direct_cost_selector_view.sql --<--<--
IF OBJECT_ID('finance.direct_cost_selector_view') IS NOT NULL
DROP VIEW finance.direct_cost_selector_view;

GO


CREATE VIEW finance.direct_cost_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS direct_cost_id,
    finance.account_scrud_view.account_name AS direct_cost_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20500));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.dividends_paid_selector_view.sql --<--<--
IF OBJECT_ID('finance.dividends_paid_selector_view') IS NOT NULL
DROP VIEW finance.dividends_paid_selector_view;

GO


CREATE VIEW finance.dividends_paid_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS dividends_paid_id,
    finance.account_scrud_view.account_name AS dividends_paid_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15400));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.dividends_received_selector_view.sql --<--<--
IF OBJECT_ID('finance.dividends_received_selector_view') IS NOT NULL
DROP VIEW finance.dividends_received_selector_view;

GO


CREATE VIEW finance.dividends_received_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS dividends_received_id,
    finance.account_scrud_view.account_name AS dividends_received_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20301));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.expense_selector_view.sql --<--<--
IF OBJECT_ID('finance.expense_selector_view') IS NOT NULL
DROP VIEW finance.expense_selector_view;

GO

CREATE VIEW finance.expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS expense_id,
    finance.account_scrud_view.account_name AS expense_name
FROM finance.account_scrud_view
WHERE account_master_id > 20400;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.financial_expense_selector_view.sql --<--<--
IF OBJECT_ID('finance.financial_expense_selector_view') IS NOT NULL
DROP VIEW finance.financial_expense_selector_view;

GO


CREATE VIEW finance.financial_expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS financial_expense_id,
    finance.account_scrud_view.account_name AS financial_expense_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20700));

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.financial_income_selector_view.sql --<--<--
IF OBJECT_ID('finance.financial_income_selector_view') IS NOT NULL
DROP VIEW finance.financial_income_selector_view;

GO


CREATE VIEW finance.financial_income_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS financial_income_id,
    finance.account_scrud_view.account_name AS financial_income_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20300));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.fixed_asset_selector_view.sql --<--<--
IF OBJECT_ID('finance.fixed_asset_selector_view') IS NOT NULL
DROP VIEW finance.fixed_asset_selector_view;

GO



CREATE VIEW finance.fixed_asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS fixed_asset_id,
    finance.account_scrud_view.account_name AS fixed_asset_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10200));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.income_selector_view.sql --<--<--
IF OBJECT_ID('finance.income_selector_view') IS NOT NULL
DROP VIEW finance.income_selector_view;

GO

CREATE VIEW finance.income_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS income_id,
    finance.account_scrud_view.account_name AS income_name
FROM finance.account_scrud_view
WHERE account_master_id BETWEEN 20100 AND 20399;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.income_tax_expense_selector_view.sql --<--<--
IF OBJECT_ID('finance.income_tax_expense_selector_view') IS NOT NULL
DROP VIEW finance.income_tax_expense_selector_view;

GO


CREATE VIEW finance.income_tax_expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS income_tax_expense_id,
    finance.account_scrud_view.account_name AS income_tax_expense_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20800));

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.interest_expense_selector_view.sql --<--<--
IF OBJECT_ID('finance.interest_expense_selector_view') IS NOT NULL
DROP VIEW finance.interest_expense_selector_view;

GO


CREATE VIEW finance.interest_expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS interest_expense_id,
    finance.account_scrud_view.account_name AS interest_expense_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20701));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.liability_selector_view.sql --<--<--
IF OBJECT_ID('finance.liability_selector_view') IS NOT NULL
DROP VIEW finance.liability_selector_view;

GO

CREATE VIEW finance.liability_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS liability_id,
    finance.account_scrud_view.account_name AS liability_name
FROM finance.account_scrud_view
WHERE account_master_id BETWEEN 15000 AND 19999;

GO

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.long_term_liability_selector_view.sql --<--<--
IF OBJECT_ID('finance.long_term_liability_selector_view') IS NOT NULL
DROP VIEW finance.long_term_liability_selector_view;

GO


CREATE VIEW finance.long_term_liability_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS long_term_liability_id,
    finance.account_scrud_view.account_name AS long_term_liability_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15100));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.non_operating_income_selector_view.sql --<--<--
IF OBJECT_ID('finance.non_operating_income_selector_view') IS NOT NULL
DROP VIEW finance.non_operating_income_selector_view;

GO


CREATE VIEW finance.non_operating_income_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS non_operating_income_id,
    finance.account_scrud_view.account_name AS non_operating_income_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20200));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.operating_expense_selector_view.sql --<--<--
IF OBJECT_ID('finance.operating_expense_selector_view') IS NOT NULL
DROP VIEW finance.operating_expense_selector_view;

GO


CREATE VIEW finance.operating_expense_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS operating_expense_id,
    finance.account_scrud_view.account_name AS operating_expense_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20600));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.other_asset_selector_view.sql --<--<--
IF OBJECT_ID('finance.other_asset_selector_view') IS NOT NULL
DROP VIEW finance.other_asset_selector_view;

GO


CREATE VIEW finance.other_asset_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS other_asset_id,
    finance.account_scrud_view.account_name AS other_asset_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10300));



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.payable_account_selector_view.sql --<--<--
IF OBJECT_ID('finance.payable_account_selector_view') IS NOT NULL
DROP VIEW finance.payable_account_selector_view;

GO



CREATE VIEW finance.payable_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS payable_account_id,
    finance.account_scrud_view.account_name AS payable_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15010));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.property_plant_equipment_selector_view.sql --<--<--
IF OBJECT_ID('finance.property_plant_equipment_selector_view') IS NOT NULL
DROP VIEW finance.property_plant_equipment_selector_view;

GO


CREATE VIEW finance.property_plant_equipment_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS property_plant_equipment_id,
    finance.account_scrud_view.account_name AS property_plant_equipment_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10201));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.receivable_account_selector_view.sql --<--<--
IF OBJECT_ID('finance.receivable_account_selector_view') IS NOT NULL
DROP VIEW finance.receivable_account_selector_view;

GO



CREATE VIEW finance.receivable_account_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS receivable_account_id,
    finance.account_scrud_view.account_name AS receivable_account_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(10110));

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.retained_earning_selector_view.sql --<--<--
IF OBJECT_ID('finance.retained_earning_selector_view') IS NOT NULL
DROP VIEW finance.retained_earning_selector_view;

GO


CREATE VIEW finance.retained_earning_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS retained_earning_id,
    finance.account_scrud_view.account_name AS retained_earning_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15300));



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.revenue_selector_view.sql --<--<--
IF OBJECT_ID('finance.revenue_selector_view') IS NOT NULL
DROP VIEW finance.revenue_selector_view;

GO


CREATE VIEW finance.revenue_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS revenue_id,
    finance.account_scrud_view.account_name AS revenue_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(20100));

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.salary_payable_selector_view.sql --<--<--
IF OBJECT_ID('finance.salary_payable_selector_view') IS NOT NULL
DROP VIEW finance.salary_payable_selector_view;

GO


CREATE VIEW finance.salary_payable_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS salary_payable_id,
    finance.account_scrud_view.account_name AS salary_payable_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15011));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.selector-views/finance.shareholders_equity_selector_view.sql --<--<--
IF OBJECT_ID('finance.shareholders_equity_selector_view') IS NOT NULL
DROP VIEW finance.shareholders_equity_selector_view;

GO


CREATE VIEW finance.shareholders_equity_selector_view
AS
SELECT 
    finance.account_scrud_view.account_id AS shareholders_equity_id,
    finance.account_scrud_view.account_name AS shareholders_equity_name
FROM finance.account_scrud_view
WHERE account_master_id IN(SELECT * FROM finance.get_account_master_ids(15200));


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/0. finance.transaction_view.sql --<--<--
IF OBJECT_ID('finance.transaction_view') IS NOT NULL
DROP VIEW finance.transaction_view;

GO


CREATE VIEW finance.transaction_view
AS
SELECT
    finance.transaction_master.transaction_master_id,
    finance.transaction_master.transaction_counter,
    finance.transaction_master.transaction_code,
    finance.transaction_master.book,
    finance.transaction_master.value_date,
    finance.transaction_master.transaction_ts,
    finance.transaction_master.login_id,
    finance.transaction_master.user_id,
    finance.transaction_master.office_id,
    finance.transaction_master.cost_center_id,
    finance.transaction_master.reference_number,
    finance.transaction_master.statement_reference AS master_statement_reference,
    finance.transaction_master.last_verified_on,
    finance.transaction_master.verified_by_user_id,
    finance.transaction_master.verification_status_id,
    finance.transaction_master.verification_reason,
    finance.transaction_details.transaction_detail_id,
    finance.transaction_details.tran_type,
    finance.transaction_details.account_id,
    finance.accounts.account_number,
    finance.accounts.account_name,
    finance.account_masters.normally_debit,
    finance.account_masters.account_master_code,
    finance.account_masters.account_master_name,
    finance.accounts.account_master_id,
    finance.accounts.confidential,
    finance.transaction_details.statement_reference,
    finance.transaction_details.cash_repository_id,
    finance.transaction_details.currency_code,
    finance.transaction_details.amount_in_currency,
    finance.transaction_details.local_currency_code,
    finance.transaction_details.amount_in_local_currency
FROM finance.transaction_master
INNER JOIN finance.transaction_details
ON finance.transaction_master.transaction_master_id = finance.transaction_details.transaction_master_id
INNER JOIN finance.accounts
ON finance.transaction_details.account_id = finance.accounts.account_id
INNER JOIN finance.account_masters
ON finance.accounts.account_master_id = finance.account_masters.account_master_id
WHERE finance.transaction_master.deleted = 0;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/1. finance.verified_transaction_view.sql --<--<--
IF OBJECT_ID('finance.verified_transaction_view') IS NOT NULL
DROP VIEW finance.verified_transaction_view --CASCADE;

GO



CREATE VIEW finance.verified_transaction_view
AS
SELECT * FROM finance.transaction_view
WHERE verification_status_id > 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/2.finance.verified_transaction_mat_view.sql --<--<--
IF OBJECT_ID('finance.verified_transaction_mat_view') IS NOT NULL
DROP VIEW finance.verified_transaction_mat_view--CASCADE;

GO

CREATE  VIEW finance.verified_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_view;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/3. finance.verified_cash_transaction_mat_view.sql --<--<--
IF OBJECT_ID('finance.verified_cash_transaction_mat_view') IS NOT NULL
DROP VIEW finance.verified_cash_transaction_mat_view;

GO

CREATE VIEW finance.verified_cash_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_mat_view
WHERE finance.verified_transaction_mat_view.transaction_master_id
IN
(
    SELECT finance.verified_transaction_mat_view.transaction_master_id 
    FROM finance.verified_transaction_mat_view
    WHERE account_master_id IN(10101, 10102) --Cash and Bank A/C
);

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/finance.account_view.sql --<--<--
IF OBJECT_ID('finance.account_view') IS NOT NULL
DROP VIEW finance.account_view;

GO



CREATE VIEW finance.account_view
AS
SELECT
    finance.accounts.account_id,
    finance.accounts.account_number + ' (' + finance.accounts.account_name + ')' AS account,
    finance.accounts.account_number,
    finance.accounts.account_name,
    finance.accounts.description,
    finance.accounts.external_code,
    finance.accounts.currency_code,
    finance.accounts.confidential,
    finance.account_masters.normally_debit,
    finance.accounts.is_transaction_node,
    finance.accounts.sys_type,
    finance.accounts.parent_account_id,
    parent_accounts.account_number AS parent_account_number,
    parent_accounts.account_name AS parent_account_name,
    parent_accounts.account_number + ' (' + parent_accounts.account_name + ')' AS parent_account,
    finance.account_masters.account_master_id,
    finance.account_masters.account_master_code,
    finance.account_masters.account_master_name,
    finance.has_child_accounts(finance.accounts.account_id) AS has_child
FROM finance.account_masters
INNER JOIN finance.accounts 
ON finance.account_masters.account_master_id = finance.accounts.account_master_id
LEFT OUTER JOIN finance.accounts AS parent_accounts 
ON finance.accounts.parent_account_id = parent_accounts.account_id
WHERE finance.account_masters.deleted = 0;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/finance.frequency_dates.sql --<--<--
IF OBJECT_ID('finance.frequency_date_view') IS NOT NULL
DROP VIEW finance.frequency_date_view;

GO



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


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/finance.transaction_verification_status_view.sql --<--<--
IF OBJECT_ID('finance.transaction_verification_status_view') IS NOT NULL
DROP VIEW finance.transaction_verification_status_view;

GO

CREATE VIEW finance.transaction_verification_status_view
AS
SELECT
    finance.transaction_master.transaction_master_id,
    finance.transaction_master.user_id,
    finance.transaction_master.office_id,
    finance.transaction_master.verification_status_id, 
    account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) AS verifier_name,
    finance.transaction_master.verified_by_user_id,
    finance.transaction_master.last_verified_on, 
    finance.transaction_master.verification_reason
FROM finance.transaction_master;

GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/finance.trial_balance_view.sql --<--<--
IF OBJECT_ID('finance.trial_balance_view') IS NOT NULL
DROP VIEW finance.trial_balance_view;

GO

CREATE VIEW finance.trial_balance_view
AS
SELECT finance.get_account_name_by_account_id(account_id) AS account, 
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE NULL END) AS debit,
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE NULL END) AS Credit
FROM finance.verified_transaction_view
GROUP BY account_id;

GO



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/99.ownership.sql --<--<--
EXEC sp_addrolemember  @rolename = 'db_owner', @membername  = 'frapid_db_user'


EXEC sp_addrolemember  @rolename = 'db_datareader', @membername  = 'report_user'


GO


DECLARE @proc sysname
DECLARE @cmd varchar(8000)

DECLARE cur CURSOR FOR 
SELECT '[' + schema_name(schema_id) + '].[' + name + ']' FROM sys.objects
WHERE type IN('FN')
AND is_ms_shipped = 0
ORDER BY 1
OPEN cur
FETCH next from cur into @proc
WHILE @@FETCH_STATUS = 0
BEGIN
     SET @cmd = 'GRANT EXEC ON ' + @proc + ' TO report_user';
     EXEC (@cmd)

     FETCH next from cur into @proc
END
CLOSE cur
DEALLOCATE cur

GO

