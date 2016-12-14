-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
EXECUTE dbo.drop_schema 'finance';
GO
CREATE SCHEMA finance;
GO


CREATE TABLE finance.verification_statuses
(
    verification_status_id                  smallint PRIMARY KEY,
    verification_status_name                national character varying(128) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE TABLE finance.frequencies
(
    frequency_id                            integer IDENTITY PRIMARY KEY,
    frequency_code                          national character varying(12) NOT NULL,
    frequency_name                          national character varying(50) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);


CREATE UNIQUE INDEX cash_repositories_cash_repository_code_uix
ON finance.cash_repositories(office_id, cash_repository_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX cash_repositories_cash_repository_name_uix
ON finance.cash_repositories(office_id, cash_repository_name)
WHERE deleted = 0;


CREATE TABLE finance.fiscal_year
(
    fiscal_year_code                        national character varying(12) PRIMARY KEY,
    fiscal_year_name                        national character varying(50) NOT NULL,
    starts_from                             date NOT NULL,
    ends_on                                 date NOT NULL,
    eod_required                            bit NOT NULL DEFAULT(1),
    office_id                                integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    account_name                            national character varying(100) NOT NULL,
    description                             national character varying(200) NULL,
    confidential                            bit NOT NULL CONSTRAINT accounts_confidential_df DEFAULT(0),
    is_transaction_node                     bit NOT NULL --Non transaction nodes cannot be used in transaction.
                                            CONSTRAINT accounts_is_transaction_node_df DEFAULT(1),
    sys_type                                bit NOT NULL CONSTRAINT accounts_sys_type_df DEFAULT(0),
    parent_account_id                       integer NULL REFERENCES finance.accounts,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_code_uix
ON finance.cash_flow_headings(cash_flow_heading_code)
WHERE deleted = 0;

CREATE UNIQUE INDEX cash_flow_headings_cash_flow_heading_name_uix
ON finance.cash_flow_headings(cash_flow_heading_code)
WHERE deleted = 0;



CREATE TABLE finance.bank_accounts
(
    bank_account_id                            int IDENTITY PRIMARY KEY,
    account_id                              integer REFERENCES finance.accounts,                                            
    maintained_by_user_id                   integer NOT NULL REFERENCES account.users,
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE TABLE finance.transaction_types
(
    transaction_type_id                     smallint PRIMARY KEY,
    transaction_type_code                   national character varying(4),
    transaction_type_name                   national character varying(100),
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
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
                                            DEFAULT(GETDATE()),
    login_id                                bigint NOT NULL REFERENCES account.logins,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    cost_center_id                          integer REFERENCES finance.cost_centers,
    reference_number                        national character varying(24),
    statement_reference                     national character varying(2000),
    last_verified_on                        DATETIMEOFFSET, 
    verified_by_user_id                     integer REFERENCES account.users,
    verification_status_id                  smallint NOT NULL REFERENCES finance.verification_statuses   
                                            DEFAULT(0/*Awaiting verification*/),
    verification_reason                     national character varying(128) NOT NULL DEFAULT(''),
    cascading_tran_id                         bigint REFERENCES finance.transaction_master,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX transaction_master_transaction_code_uix
ON finance.transaction_master(transaction_code)
WHERE deleted = 0;

CREATE INDEX transaction_master_cascading_tran_id_inx
ON finance.transaction_master(cascading_tran_id)
WHERE deleted = 0;

CREATE TABLE finance.transaction_documents
(
    document_id                                bigint IDENTITY PRIMARY KEY,
    transaction_master_id                    bigint NOT NULL REFERENCES finance.transaction_master,
    original_file_name                        national character varying(500) NOT NULL,
    file_extension                            national character varying(50),
    file_path                                national character varying(2000) NOT NULL,
    memo                                    national character varying(2000),
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);


CREATE TABLE finance.transaction_details
(
    transaction_detail_id                   bigint IDENTITY PRIMARY KEY,
    transaction_master_id                   bigint NOT NULL REFERENCES finance.transaction_master,
    value_date                              date NOT NULL,
    book_date                                  date NOT NULL,
    tran_type                               national character varying(4) NOT NULL CHECK(tran_type IN ('Dr', 'Cr')),
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    statement_reference                     national character varying(2000),
    cash_repository_id                      integer REFERENCES finance.cash_repositories,
    currency_code                           national character varying(12) NOT NULL REFERENCES core.currencies,
    amount_in_currency                      dbo.money_strict NOT NULL,
    local_currency_code                     national character varying(12) NOT NULL REFERENCES core.currencies,
    er                                      dbo.decimal_strict NOT NULL,
    amount_in_local_currency                dbo.money_strict NOT NULL,  
    office_id                               integer NOT NULL REFERENCES core.offices,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE())
);


CREATE TABLE finance.card_types
(
    card_type_id                            integer PRIMARY KEY,
    card_type_code                          national character varying(12) NOT NULL,
    card_type_name                          national character varying(100) NOT NULL,
    audit_user_id                           integer REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
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
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)            
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
    rate                                    dbo.decimal_strict NOT NULL,
    customer_pays_fee                       bit NOT NULL DEFAULT(0),
    account_id                              integer NOT NULL REFERENCES finance.accounts,
    statement_reference                     national character varying(2000) NOT NULL DEFAULT(''),
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)            
);

CREATE UNIQUE INDEX merchant_fee_setup_merchant_account_id_payment_card_id_uix
ON finance.merchant_fee_setup(merchant_account_id, payment_card_id)
WHERE deleted = 0;


CREATE TABLE finance.exchange_rates
(
    exchange_rate_id                        bigint IDENTITY PRIMARY KEY,
    updated_on                              DATETIMEOFFSET NOT NULL   
                                            CONSTRAINT exchange_rates_updated_on_df 
                                            DEFAULT(GETDATE()),
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
    unit                                    dbo.integer_strict NOT NULL,
    exchange_rate                           dbo.decimal_strict NOT NULL
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
    verification_limit                      dbo.money_strict2 NOT NULL DEFAULT(0),
    can_self_verify                         bit NOT NULL DEFAULT(0),
    self_verification_limit                 dbo.money_strict2 NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               bit NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)            
);


CREATE TABLE finance.auto_verification_policy
(
    auto_verification_policy_id             integer IDENTITY PRIMARY KEY,
    user_id                                 integer NOT NULL REFERENCES account.users,
    office_id                               integer NOT NULL REFERENCES core.offices,
    verification_limit                      dbo.money_strict2 NOT NULL DEFAULT(0),
    effective_from                          date NOT NULL,
    ends_on                                 date NOT NULL,
    is_active                               bit NOT NULL,
    audit_user_id                           integer NULL REFERENCES account.users,            
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)                                            
);

CREATE TABLE finance.tax_setups
(
    tax_setup_id                            int IDENTITY PRIMARY KEY,
    office_id                                integer NOT NULL REFERENCES core.offices,
    income_tax_rate                            dbo.decimal_strict NOT NULL,
    income_tax_account_id                    integer NOT NULL REFERENCES finance.accounts,
    sales_tax_rate                            dbo.decimal_strict NOT NULL,
    sales_tax_account_id                    integer NOT NULL REFERENCES finance.accounts,
    audit_user_id                           integer NULL REFERENCES account.users,
    audit_ts                                DATETIMEOFFSET DEFAULT(GETDATE()),
    deleted                                    bit DEFAULT(0)
);

CREATE UNIQUE INDEX tax_setup_office_id_uix
ON finance.tax_setups(office_id)
WHERE deleted = 0;


CREATE TABLE finance.routines
(
    routine_id                              integer IDENTITY NOT NULL PRIMARY KEY,
    "order"                                 integer NOT NULL,
    routine_code                            national character varying(12) NOT NULL,
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
    DECLARE @verification_limit             dbo.money_strict2;
    DECLARE @posted_amount                  dbo.money_strict2;
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
    AND GETDATE() >= effective_from
    AND GETDATE() <= ends_on
    AND finance.auto_verification_policy.deleted = 0;

    IF(@has_policy= 1)
    BEGIN
        UPDATE finance.transaction_master
        SET 
            last_verified_on = GETDATE(),
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
        RAISERROR('No auto verification policy found for this user.', 10, 1);
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
RETURNS dbo.decimal_strict2
AS
BEGIN
    DECLARE @unit                           dbo.integer_strict2 = 0;
    DECLARE @exchange_rate                  dbo.decimal_strict2 = 0;
    DECLARE @from_source_currency           dbo.decimal_strict2 = finance.get_exchange_rate(@office_id, @source_currency_code);
    DECLARE @from_destination_currency      dbo.decimal_strict2 = finance.get_exchange_rate(@office_id, @destination_currency_code);

    IF(@source_currency_code = @destination_currency_code)
    BEGIN
        RETURN 1;
    END;
        
    RETURN @from_source_currency / @from_destination_currency ; 
END;

--SELECT * FROM  finance.convert_exchange_rate(1, 'USD', 'NPR')


GO

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.create_routine.sql --<--<--
IF OBJECT_ID('finance.create_routine') IS NOT NULL
DROP PROCEDURE finance.create_routine;

GO

CREATE PROCEDURE finance.create_routine(@routine_code national character varying(12), @routine national character varying(128), @order integer)
AS
BEGIN
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
    RETURN;
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND finance.frequency_setups.deleted = 0;
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

    SELECT MAX(value_date) + 1
    INTO @date
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
        SELECT starts_from 
        INTO @date
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 2
    AND finance.frequency_setups.deleted = 0;
END;




GO

IF OBJECT_ID('finance.get_quarter_start_date(@office_id') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date(@office_id;

GO

CREATE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT MAX(value_date) + 1
    INTO @date
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
        SELECT starts_from 
        INTO @date
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 3
    AND finance.frequency_setups.deleted = 0;
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

    SELECT MAX(value_date) + 1
    INTO @date
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
        SELECT starts_from 
        INTO @date
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
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 4
    AND finance.frequency_setups.deleted = 0;
END;



GO

IF OBJECT_ID('') IS NOT NULL
DROP FUNCTION;

GO

CREATE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT starts_from 
    INTO @date
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
    RETURN
    (
	    SELECT finance.fiscal_year.eod_required
	    FROM finance.fiscal_year
	    WHERE finance.fiscal_year.office_id = @office_id
    );
END;



--SELECT finance.eod_required(1);

GO


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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_account_ids.sql --<--<--
IF OBJECT_ID('finance.get_account_ids') IS NOT NULL
DROP FUNCTION finance.get_account_ids;

GO

CREATE FUNCTION finance.get_account_ids(root_account_id integer)
RETURNS @result TABLE
(
    account_id              integer
)
AS
BEGIN
    INSERT INTO @result
    (
        WITH account_cte(account_id, path) AS (
         SELECT
            tn.account_id,  tn.account_id AS path
            FROM finance.accounts AS tn 
            WHERE tn.account_id = @root_account_id
            AND tn.deleted = 0
        UNION ALL
         SELECT
            c.account_id, (p.path + '->' + c.account_id
            FROM account_cte AS p, finance.accounts AS c WHERE parent_account_id = p.account_id
        )

        SELECT account_id FROM account_cte
    );

    RETURN;
END;




GO


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
    id                      integer,
    value_date              date,
    book_date               date,
    tran_code               national character varying(50),
    reference_number        national character varying(24),
    statement_reference     national character varying(2000),
    debit                   decimal(24, 4),
    credit                  decimal(24, 4),
    balance                 decimal(24, 4),
    office national character varying(1000),
    book                    national character varying(50),
    account_id              integer,
    account_number national character varying(24),
    account                 national character varying(1000),
    posted_on               DATETIMEOFFSET,
    posted_by               national character varying(1000),
    approved_by             national character varying(1000),
    verification_status     integer,
    flag_bg                 national character varying(1000),
    flag_fg                 national character varying(1000)
)
AS
BEGIN
    DECLARE @normally_debit bit;

    @normally_debit             = finance.is_normally_debit(@account_id);

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
    

    INSERT INTO @result(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master. transaction_code,
        finance.transaction_master.reference_number,
        finance.transaction_details.statement_reference,
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
        finance.transaction_master.book_date,
        finance.transaction_master.value_date,
        finance.transaction_master.last_verified_on;



    UPDATE @result
    SET balance = c.balance
    FROM
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
        ORDER BY temp_account_statement.id
    ) AS c
    WHERE id = c.id;


    UPDATE @result SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM finance.accounts
    WHERE account_id = finance.accounts.account_id;


--     UPDATE temp_account_statement SET
--         flag_bg = core.get_flag_background_color(core.get_flag_type_id(@user_id, 'account_statement', 'transaction_code', temp_account_statement.tran_code)),
--         flag_fg = core.get_flag_foreground_color(core.get_flag_type_id(@user_id, 'account_statement', 'transaction_code', temp_account_statement.tran_code));


    IF(@normally_debit)
    BEGIN
        UPDATE @result SET balance = balance * -1;
    END;

    RETURN;
END;



--SELECT * FROM finance.get_account_statement('1-1-2010','1-1-2020',1,1,1);


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
IF OBJECT_ID('finance.get_cash_repository_balance') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_balance;

GO

CREATE FUNCTION finance.get_cash_repository_balance(@cash_repository_id integer, @currency_code national character varying(12))
RETURNS dbo.money_strict2
AS
BEGIN
    DECLARE @debit dbo.money_strict2;
    DECLARE @credit dbo.money_strict2;

    SELECT COALESCE(SUM(amount_in_currency), 0) INTO @debit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Dr';

    SELECT COALESCE(SUM(amount_in_currency), 0) INTO @credit
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
RETURNS dbo.decimal_strict2
AS
BEGIN
    DECLARE @local_currency_code        national character varying(12)= '';
    DECLARE @unit                       dbo.integer_strict2 = 0;
    DECLARE @exchange_rate              dbo.decimal_strict2 = 0;

    SELECT core.offices.currency_code
    INTO @local_currency_code
    FROM core.offices
    WHERE core.offices.office_id=@office_id
    AND core.offices.deleted = 0;

    IF(@local_currency_code = @currency_code)
    BEGIN
        RETURN 1;
    END;

    SELECT unit, exchange_rate
    INTO @unit, @exchange_rate
    FROM finance.exchange_rate_details
    INNER JOIN finance.exchange_rates
    ON finance.exchange_rate_details.exchange_rate_id = finance.exchange_rates.exchange_rate_id
    WHERE finance.exchange_rates.office_id=@office_id
    AND foreign_currency_code=@currency_code;

    IF(@unit = 0)
    BEGIN
        RETURN 0;
    END;
    
    RETURN @exchange_rate/_unit;    
END;


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

    SELECT MIN(value_date)
    INTO @end_date
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

    SELECT MAX(value_date) + 1 
    INTO @start_date
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
        SELECT starts_from 
        INTO @start_date
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

    SELECT MAX(value_date) + 1 
    INTO @start_date
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
        SELECT starts_from 
        INTO @start_date
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

CREATE FUNCTION finance.get_income_tax_provison_amount(@office_id integer, @profit decimal(24, 4), @balance decimal(24, 4))
RETURNS  decimal(24, 4)
AS
BEGIN
    DECLARE @rate real;

    @rate = finance.get_income_tax_rate(@office_id);

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
RETURNS dbo.decimal_strict
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

    SELECT INTO @ret_val
        COALESCE(MAX(transaction_counter),0)
    FROM finance.transaction_master
    WHERE finance.transaction_master.value_date=@value_date
    AND finance.transaction_master.deleted = 0;

    IF @ret_val IS NULL
    BEGIN
        RETURN 1;
    END
    ELSE
    BEGIN
        RETURN (@ret_val + 1);
    END;
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
    tran_code national character varying(50),
    statement_reference             national character varying(2000),
    debit                           decimal(24, 4),
    credit                          decimal(24, 4),
    balance                         decimal(24, 4),
    office national character varying(1000),
    book                    national character varying(50),
    account_id                      integer,
    account_number national character varying(24),
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
    DECLARE @net_profit             decimal(24, 4) = 0;
    DECLARE @income_tax_rate        real           = 0;
    DECLARE @itp                    decimal(24, 4) = 0;

    @date_from                      = finance.get_fiscal_year_start_date(@office_id);
    @net_profit                     = finance.get_net_profit(@date_from, @date_to, @office_id, @factor);
    @income_tax_rate                = finance.get_income_tax_rate(@office_id);

    IF(COALESCE(@factor , 0) = 0)
    BEGIN
        @factor                        = 1;
    END; 

    IF(@income_tax_rate != 0)
    BEGIN
        @itp                            = (@net_profit * @income_tax_rate) / (100 - @income_tax_rate);
    END;

    DECLARE @retained_earnings TABLE
    (
        id                          integer IDENTITY,
        value_date                  date,
        tran_code national character varying(50),
        statement_reference         national character varying(2000),
        debit                       decimal(24, 4),
        credit                      decimal(24, 4),
        balance                     decimal(24, 4),
        office national character varying(1000),
        book                        national character varying(50),
        account_id                  integer,
        account_number national character varying(24),
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
    debit = @retained_earnings.credit * -1,
    credit = 0
    WHERE @retained_earnings.credit < 0;


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
    FROM
    (
        SELECT
            @retained_earnings.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM @retained_earnings
        LEFT JOIN @retained_earnings AS c 
            ON (c.id <= @retained_earnings.id)
        GROUP BY @retained_earnings.id
        ORDER BY @retained_earnings.id
    ) AS c
    WHERE @retained_earnings.id = c.id;

    UPDATE @retained_earnings SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM finance.accounts
    WHERE @retained_earnings.account_id = finance.accounts.account_id;


    UPDATE @retained_earnings SET debit = NULL WHERE @retained_earnings.debit = 0;
    UPDATE @retained_earnings SET credit = NULL WHERE @retained_earnings.credit = 0;

    INSERT INTO @result
    SELECT * FROM @retained_earnings
    ORDER BY id;

    RETURN;
END;




--SELECT * FROM finance.get_retained_earnings_statement('7/16/2015', 2, 1000);

--SELECT * FROM finance.get_retained_earnings('7/16/2015', 2, 100);



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_root_account_id.sql --<--<--
IF OBJECT_ID('finance.get_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_root_account_id;

GO

CREATE FUNCTION finance.get_root_account_id(@account_id integer, @parent bigint default 0)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;

    SELECT 
        parent_account_id
        INTO @parent_account_id
    FROM finance.accounts
    WHERE finance.accounts.account_id=@account_id
    AND finance.accounts.deleted = 0;

    

    IF(@parent_account_id IS NULL)
    BEGIN
        RETURN @account_id;
    ELSE
    BEGIN
        RETURN finance.get_root_account_id(@parent_account_id, @account_id);
    END; 
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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_second_root_account_id.sql --<--<--
IF OBJECT_ID('finance.get_second_root_account_id') IS NOT NULL
DROP FUNCTION finance.get_second_root_account_id;

GO

CREATE FUNCTION finance.get_second_root_account_id(@account_id integer, @parent bigint default 0)
RETURNS integer
AS
BEGIN
    DECLARE @parent_account_id integer;

    SELECT 
        parent_account_id
        INTO @parent_account_id
    FROM finance.accounts
    WHERE account_id=@account_id;

    IF(@parent_account_id IS NULL)
    BEGIN
        RETURN @parent;
    END
    ELSE
    BEGIN
        RETURN finance.get_second_root_account_id(@parent_account_id, @account_id);
    END; 
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

    @ret_val= finance.get_new_transaction_counter(@value_date) + '-' + CONVERT(varchar(10), @value_date, 120) + '-' + CAST(@office_id varchar(100)) + '-' + CAST(@user_id varchar(100)) + '-' + CAST(@login_id varchar(100))   + '-' +  CONVERT(VARCHAR(10), GETDATE(), 108);
    RETURN @ret_val;
END;





GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_value_date.sql --<--<--
IF OBJECT_ID('finance.get_value_date') IS NOT NULL
DROP FUNCTION finance.get_value_date;

GO

CREATE OR REPLACE FUNCTION finance.get_value_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE this            RECORD;
    DECLARE @value_date     date;

    SELECT * FROM finance.day_operation
    WHERE office_id = @office_id
    AND value_date =
    (
        SELECT MAX(value_date)
        FROM finance.day_operation
        WHERE office_id = @office_id
    ) INTO this;

    IF(this.day_id IS NOT NULL)
    BEGIN
        IF(this.completed)
        BEGIN
            @value_date  = this.value_date + interval '1' day;
        END
        ELSE
        BEGIN
            @value_date  = this.value_date;    
        END;
    END;

    IF(@value_date IS NULL)
    BEGIN
        @value_date = GETDATE() AT time zone config.get_server_timezone();
    END;
    
    RETURN @value_date;
END;

GO

IF OBJECT_ID('finance.get_month_end_date') IS NOT NULL
DROP FUNCTION finance.get_month_end_date;

GO

CREATE OR REPLACE FUNCTION finance.get_month_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND finance.frequency_setups.office_id = @office_id;
END;

GO

IF OBJECT_ID('finance.get_month_start_date') IS NOT NULL
DROP FUNCTION finance.get_month_start_date;

GO

CREATE OR REPLACE FUNCTION finance.get_month_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT MAX(value_date) + 1
    INTO @date
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
        SELECT starts_from 
        INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_quarter_end_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_end_date;

GO

CREATE OR REPLACE FUNCTION finance.get_quarter_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 2
    AND finance.frequency_setups.office_id = @office_id;
END;


GO


IF OBJECT_ID('finance.get_quarter_start_date') IS NOT NULL
DROP FUNCTION finance.get_quarter_start_date;

GO

CREATE OR REPLACE FUNCTION finance.get_quarter_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT MAX(value_date) + 1
    INTO @date
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
        SELECT starts_from INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;

GO

IF OBJECT_ID('finance.get_fiscal_half_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_end_date;

GO

CREATE OR REPLACE FUNCTION finance.get_fiscal_half_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 3
    AND finance.frequency_setups.office_id = @office_id;
END;


GO


IF OBJECT_ID('finance.get_fiscal_half_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_half_start_date;

GO

CREATE OR REPLACE FUNCTION finance.get_fiscal_half_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT MAX(value_date) + 1 INTO @date
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
        SELECT starts_from INTO @date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = @office_id;
    END;

    RETURN @date;
END;


GO

IF OBJECT_ID('finance.get_fiscal_year_end_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_end_date;

GO

CREATE OR REPLACE FUNCTION finance.get_fiscal_year_end_date(@office_id integer)
RETURNS date
AS

BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(@office_id)
    AND frequency_id > 4
    AND finance.frequency_setups.office_id = @office_id;
END;


GO


IF OBJECT_ID('finance.get_fiscal_year_start_date') IS NOT NULL
DROP FUNCTION finance.get_fiscal_year_start_date;

GO

CREATE OR REPLACE FUNCTION finance.get_fiscal_year_start_date(@office_id integer)
RETURNS date
AS
BEGIN
    DECLARE @date               date;

    SELECT starts_from INTO @date
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
	    FROM finance.verification_statuses
	    WHERE finance.verification_statuses.verification_status_id = @verification_status_id
	    AND finance.verification_statuses.deleted = 0
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
    IF EXISTS(SELECT 0 FROM finance.accounts WHERE parent_account_id=@account_id LIMIT 1)
    BEGIN
        RETURN 1;
    END;

    RETURN 0;
END;




GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.initialize_eod_operation.sql --<--<--
IF OBJECT_ID('finance.initialize_eod_operation') IS NOT NULL
DROP PROCEDURE finance.initialize_eod_operation;

GO

CREATE PROCEDURE finance.initialize_eod_operation(@user_id integer, @office_id integer, @value_date date)
AS
BEGIN
    DECLARE this            RECORD;    

    IF(@value_date IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 10, 1);
    END;

    IF(NOT account.is_admin(@user_id))
    BEGIN
        RAISERROR('Access is denied.', 10, 1);
    END;

    IF(@value_date != finance.get_value_date(@office_id))
    BEGIN
        RAISERROR('Invalid value date.', 10, 1);
    END;

    SELECT * FROM finance.day_operation
    WHERE value_date=_value_date 
    AND office_id = @office_id INTO this;

    IF(this IS NULL)
    BEGIN
        INSERT INTO finance.day_operation(office_id, value_date, started_on, started_by)
        SELECT @office_id, @value_date, GETDATE(), @user_id;
    END
    ELSE    
    BEGIN
        RAISERROR('EOD operation was already initialized.', 10, 1);
    END;

    RETURN;
END;




--SELECT finance.initialize_eod_operation(1, 1, finance.get_value_date(1));
--delete from finance.day_operation

--select * from finance.day_operation


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
        AND account_id=_account_id
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

CREATE or replace FUNCTION finance.is_new_day_started(@office_id integer)
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


CREATE PROCEDURE finance.perform_eod_operation(@user_id integer, @login_id bigint, @office_id integer, @value_date date)
AS
BEGIN
    DECLARE @routine            national character varying(128);
    DECLARE @routine_id         integer;
    DECLARE @sql                national character varying(1000);
    DECLARE @is_error           bit= 0;
    DECLARE @notice             national character varying(1000);
    DECLARE @office_code        national character varying(50);
    DECLARE @this               TABLE
    (
        routine_id              integer,
        routine_name            national character varying(128)
    );
    DECLARE @counter            integer = 0;
    DECLARE @total_rows         integer = 0;


    IF(@value_date IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 10, 1);
    END;

    IF(NOT account.is_admin(@user_id))
    BEGIN
        RAISERROR('Access is denied.', 10, 1);
    END;

    IF(@value_date != finance.get_value_date(@office_id))
    BEGIN
        RAISERROR('Invalid value date.', 10, 1);
    END;

    SELECT * FROM finance.day_operation
    WHERE value_date=_value_date 
    AND office_id = @office_id INTO this;

    IF(this IS NULL)
    BEGIN
        RAISERROR('Invalid value date.', 10, 1);
    END
    ELSE
    BEGIN    
        IF(this.completed OR this.completed_on IS NOT NULL)
        BEGIN
            RAISERROR('End of day operation was already performed.', 10, 1);
            @is_error        = 1;
        END;
    END;

    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE value_date < @value_date
        AND verification_status_id = 0
    )
    BEGIN
        RAISERROR('Past dated transactions in verification queue.', 10, 1);
        @is_error        = 1;
    END;

    IF EXISTS
    (
        SELECT * FROM finance.transaction_master
        WHERE value_date = @value_date
        AND verification_status_id = 0
    )
    BEGIN
        RAISERROR('Please verify transactions before performing end of day operation.', 10, 1);
        @is_error        = 1;
    END;
    
    IF(NOT @is_error)
    BEGIN
        INSERT INTO @this
        SELECT routine_id, routine_name 
        FROM finance.routines 
        WHERE status = 1
        ORDER BY "order" ASC;

        @office_code        = core.get_office_code_by_office_id(@office_id);
        @notice             = 'EOD started.';
        PRINT @notice;

        SELECT @total_rows=MAX(routine_id) FROM @this;

        WHILE @counter<@total_rows
        BEGIN
            SELECT TOP 1 
                @routine_id = routine_id,
                @routine = routine_name 
            FROM @this
            WHERE routine_id >= @counter
            ORDER BY routine_id;

            PRINT @ROUTINE_ID;  

            IF(@routine_id IS NOT NULL)
            BEGIN
                SET @counter=@routine_id +1;        
            END
            ELSE
            BEGIN
                BREAK;
            END;

            @sql                    = FORMATMESSAGE('EXECUTE %s @user_id, @login_id, @office_id, @value_date;', @routine);

            PRINT @sql;

            @notice             = 'Performing ' + @routine + '.';
            PRINT @notice;

            WAITFOR DELAY '00:00:02';
            EXECUTE @sql USING @user_id, @login_id, @office_id, @value_date;

            @notice             = 'Completed  ' + @routine + '.';
            PRINT @notice;
            
            WAITFOR DELAY '00:00:02';
        END;




        UPDATE finance.day_operation SET 
            completed_on = GETDATE(), 
            completed_by = @user_id,
            completed = 1
        WHERE value_date=_value_date
        AND office_id = @office_id;

        @notice             = 'EOD of ' + @office_code + ' for ' + CAST(@value_date AS varchar(24)) + ' completed without errors.';
        PRINT @notice;

        @notice             = 'OK';
        PRINT @notice;

        SELECT 1;
        RETURN;
    END;

    SELECT 0;
    RETURN;    
END;

--SELECT * FROM finance.perform_eod_operation(1, 1, 1, finance.get_value_date(1));


GO


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
    @reason                                 national character varying
)
AS
BEGIN
    DECLARE @transaction_posted_by          integer;
    DECLARE @book                           national character varying(50);
    DECLARE @can_verify                     bit;
    DECLARE @verification_limit             dbo.money_strict2;
    DECLARE @can_self_verify                bit;
    DECLARE @self_verification_limit        dbo.money_strict2;
    DECLARE @posted_amount                  dbo.money_strict2;
    DECLARE @has_policy                     bit= 0;
    DECLARE @journal_date                   date;
    DECLARE @journal_office_id              integer;
    DECLARE @cascading_tran_id              bigint;

    SELECT
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.office_id,
        finance.transaction_master.user_id
    INTO
        @book,
        @journal_date,
        @journal_office_id,
        @transaction_posted_by  
    FROM
    finance.transaction_master
    WHERE finance.transaction_master.transaction_master_id=_transaction_master_id
    AND finance.transaction_master.deleted = 0;


    IF(@journal_office_id <> @office_id)
    BEGIN
        RAISERROR('Access is denied. You cannot verify a transaction of another office.', 10, 1);
    END;
        
    SELECT
        SUM(amount_in_local_currency)
    INTO
        @posted_amount
    FROM finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = @transaction_master_id
    AND finance.transaction_details.tran_type='Cr';


    SELECT
        1,
        can_verify,
        verification_limit,
        can_self_verify,
        self_verification_limit
    INTO
        @has_policy,
        @can_verify,
        @verification_limit,
        @can_self_verify,
        @self_verification_limit
    FROM finance.journal_verification_policy
    WHERE finance.journal_verification_policy.user_id=_user_id
    AND finance.journal_verification_policy.office_id = @office_id
    AND finance.journal_verification_policy.is_active= 1
    AND GETDATE() >= effective_from
    AND GETDATE() <= ends_on
    AND finance.journal_verification_policy.deleted = 0;

    IF(NOT @can_self_verify AND @user_id = @transaction_posted_by)
    BEGIN
        @can_verify = 0;
    END;

    IF(@has_policy)
    BEGIN
        IF(@can_verify)
        BEGIN
        
            SELECT cascading_tran_id
            INTO @cascading_tran_id
            FROM finance.transaction_master
            WHERE finance.transaction_master.transaction_master_id=_transaction_master_id
            AND finance.transaction_master.deleted = 0;
            
            UPDATE finance.transaction_master
            SET 
                last_verified_on = GETDATE(),
                verified_by_user_id=_user_id,
                verification_status_id=_verification_status_id,
                verification_reason=_reason
            WHERE
                finance.transaction_master.transaction_master_id=_transaction_master_id
            OR 
                finance.transaction_master.cascading_tran_id =_transaction_master_id
            OR
            finance.transaction_master.transaction_master_id = @cascading_tran_id;


            IF(COALESCE(@cascading_tran_id, 0) = 0)
            BEGIN
                SELECT transaction_master_id
                INTO @cascading_tran_id
                FROM finance.transaction_master
                WHERE finance.transaction_master.cascading_tran_id=_transaction_master_id
                AND finance.transaction_master.deleted = 0;
            END;
            
            SELECT COALESCE(@cascading_tran_id, 0);
            RETURN;
        END
        ELSE
        BEGIN
            RAISERROR('Please ask someone else to verify your transaction.', 10, 1);
        END;
    ELSE
    BEGIN
        RAISERROR('No verification policy found for this user.', 10, 1);
    END;

    SELECT 0;
    RETURN;
END;



--SELECT * FROM finance.verify_transaction(1, 1, 1, 6, 2, 'OK');

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
    id                              bigint,
    item                            national character varying(1000),
    previous_period                 decimal(24, 4),
    current_period                  decimal(24, 4),
    account_id                      integer,
    account_number national character varying(24),
    is_retained_earning             bit
)
AS
BEGIN
    DECLARE this                    RECORD;
    DECLARE @date_from              date;

    @date_from = finance.get_fiscal_year_start_date(@office_id);

    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        @factor = 1;
    END;

    DECLARE @balance_sheet TABLE
    (
        item_id                     integer PRIMARY KEY,
        item                        national character varying(1000),
        account_number              national character varying(24),
        account_id                  integer,
        child_accounts              national character varying(MAX),
        parent_item_id              integer REFERENCES @balance_sheet(item_id),
        is_debit                    bit DEFAULT(0),
        previous_period             decimal(24, 4) DEFAULT(0),
        current_period              decimal(24, 4) DEFAULT(0),
        sort                        int,
        skip                        bit DEFAULT(0),
        is_retained_earning         bit DEFAULT(0)
    );
    
    --BS structure setup start
    INSERT INTO @balance_sheet(item_id, item, parent_item_id)
    SELECT  1,       'Assets',                              NULL            UNION ALL
    SELECT  10100,   'Current Assets',                      1               UNION ALL
    SELECT  10101,   'Cash A/C',                            1               UNION ALL
    SELECT  10102,   'Bank A/C',                            1               UNION ALL
    SELECT  10110,   'Accounts Receivable',                 10100           UNION ALL
    SELECT  10200,   'Fixed Assets',                        1               UNION ALL
    SELECT  10201,   'Property, Plants, and Equipments',    10201           UNION ALL
    SELECT  10300,   'Other Assets',                        1               UNION ALL
    SELECT  14900,   'Liabilities & Shareholders'' Equity', NULL            UNION ALL
    SELECT  15000,   'Current Liabilities',                 14900           UNION ALL
    SELECT  15010,   'Accounts Payable',                    15000           UNION ALL
    SELECT  15011,   'Salary Payable',                      15000           UNION ALL
    SELECT  15100,   'Long-Term Liabilities',               14900           UNION ALL
    SELECT  15200,   'Shareholders'' Equity',               14900           UNION ALL
    SELECT  15300,   'Retained Earnings',                   15200;

    UPDATE @balance_sheet SET is_debit = 1 WHERE @balance_sheet.item_id <= 10300;
    UPDATE @balance_sheet SET is_retained_earning = 1 WHERE @balance_sheet.item_id = 15300;
    
    INSERT INTO @balance_sheet(item_id, account_id, account_number, parent_item_id, item, is_debit, child_accounts)
    SELECT 
        row_number() OVER(ORDER BY finance.accounts.account_master_id) + (finance.accounts.account_master_id * 100) AS id,
        finance.accounts.account_id,
        finance.accounts.account_number,
        finance.accounts.account_master_id,
        finance.accounts.account_name,
        finance.account_masters.normally_debit,
        array_agg(agg)
    FROM finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id,
    finance.get_account_ids(finance.accounts.account_id) as agg
    WHERE parent_account_id IN
    (
        SELECT finance.accounts.account_id
        FROM finance.accounts
        WHERE finance.accounts.sys_type
        AND finance.accounts.account_master_id BETWEEN 10100 AND 15200
    )
    AND finance.accounts.account_master_id BETWEEN 10100 AND 15200
    GROUP BY finance.accounts.account_id, finance.account_masters.normally_debit
    ORDER BY account_master_id;


    --Updating credit balances of individual GL accounts.
    UPDATE @balance_sheet SET previous_period = tran.previous_period
    FROM
    (
        SELECT 
            @balance_sheet.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM @balance_sheet
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id IN(SELECT * FROM @balance_sheet.child_accounts)
        WHERE value_date <=_previous_period
        AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
        GROUP BY @balance_sheet.account_id
    ) AS tran
    WHERE @balance_sheet.account_id = tran.account_id;

    --Updating credit balances of individual GL accounts.
    UPDATE @balance_sheet SET current_period = tran.current_period
    FROM
    (
        SELECT 
            @balance_sheet.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM @balance_sheet
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id IN(SELECT * FROM @balance_sheet.child_accounts)
        WHERE value_date <=_current_period
        AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
        GROUP BY @balance_sheet.account_id
    ) AS tran
    WHERE @balance_sheet.account_id = tran.account_id;


    --Dividing by the factor.
    UPDATE @balance_sheet SET 
        previous_period = @balance_sheet.previous_period / @factor,
        current_period = @balance_sheet.current_period / @factor;

    --Upading balance of retained earnings
    UPDATE @balance_sheet SET 
        previous_period = finance.get_retained_earnings(@previous_period, @office_id, @factor),
        current_period = finance.get_retained_earnings(@current_period, @office_id, @factor)
    WHERE @balance_sheet.item_id = 15300;

    --Reversing assets to debit balance.
    UPDATE @balance_sheet SET 
        previous_period=@balance_sheet.previous_period*-1,
        current_period=@balance_sheet.current_period*-1 
    WHERE @balance_sheet.is_debit;



    FOR this IN 
    SELECT * FROM @balance_sheet 
    WHERE COALESCE(@balance_sheet.previous_period, 0) + COALESCE(@balance_sheet.current_period, 0) != 0 
    AND @balance_sheet.account_id IS NOT NULL
    LOOP
        UPDATE @balance_sheet SET skip = 1 WHERE this.account_id IN(SELECT * FROM @balance_sheet.child_accounts)
        AND @balance_sheet.account_id != this.account_id;
    END LOOP;

    --Updating current period amount on GL parent item by the sum of their respective child balances.
    WITH running_totals AS
    (
        SELECT @balance_sheet.parent_item_id,
        SUM(COALESCE(@balance_sheet.previous_period, 0)) AS previous_period,
        SUM(COALESCE(@balance_sheet.current_period, 0)) AS current_period
        FROM @balance_sheet
        WHERE skip = 0
        AND parent_item_id IS NOT NULL
        GROUP BY @balance_sheet.parent_item_id
    )
    UPDATE @balance_sheet SET 
        previous_period = running_totals.previous_period,
        current_period = running_totals.current_period
    FROM running_totals
    WHERE running_totals.parent_item_id = @balance_sheet.item_id
    AND @balance_sheet.item_id
    IN
    (
        SELECT parent_item_id FROM running_totals
    );


    --Updating sum amount on parent item by the sum of their respective child balances.
    UPDATE @balance_sheet SET 
        previous_period = tran.previous_period,
        current_period = tran.current_period
    FROM 
    (
        SELECT @balance_sheet.parent_item_id,
        SUM(@balance_sheet.previous_period) AS previous_period,
        SUM(@balance_sheet.current_period) AS current_period
        FROM @balance_sheet
        WHERE @balance_sheet.parent_item_id IS NOT NULL
        GROUP BY @balance_sheet.parent_item_id
    ) 
    AS tran 
    WHERE tran.parent_item_id = @balance_sheet.item_id
    AND tran.parent_item_id IS NOT NULL;


    --Updating sum amount on grandparents.
    UPDATE @balance_sheet SET 
        previous_period = tran.previous_period,
        current_period = tran.current_period
    FROM 
    (
        SELECT @balance_sheet.parent_item_id,
        SUM(@balance_sheet.previous_period) AS previous_period,
        SUM(@balance_sheet.current_period) AS current_period
        FROM @balance_sheet
        WHERE @balance_sheet.parent_item_id IS NOT NULL
        GROUP BY @balance_sheet.parent_item_id
    ) 
    AS tran 
    WHERE tran.parent_item_id = @balance_sheet.item_id;

    --Removing ledgers having zero balances
    DELETE FROM @balance_sheet
    WHERE COALESCE(@balance_sheet.previous_period, 0) + COALESCE(@balance_sheet.current_period, 0) = 0
    AND @balance_sheet.account_id IS NOT NULL;

    --Converting 0's to NULLS.
    UPDATE @balance_sheet SET previous_period = CASE WHEN @balance_sheet.previous_period = 0 THEN NULL ELSE @balance_sheet.previous_period END;
    UPDATE @balance_sheet SET current_period = CASE WHEN @balance_sheet.current_period = 0 THEN NULL ELSE @balance_sheet.current_period END;
    
    UPDATE @balance_sheet SET sort = @balance_sheet.item_id WHERE @balance_sheet.item_id < 15400;
    UPDATE @balance_sheet SET sort = @balance_sheet.parent_item_id WHERE @balance_sheet.item_id >= 15400;

    INSERT INTO @result
    SELECT
        row_number() OVER(order by @balance_sheet.sort, @balance_sheet.item_id) AS id,
        @balance_sheet.item,
        @balance_sheet.previous_period,
        @balance_sheet.current_period,
        @balance_sheet.account_id,
        @balance_sheet.account_number,
        @balance_sheet.is_retained_earning
    FROM @balance_sheet;

    RETURN;
END;



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
    DECLARE @sql                    national character varying(1000);
    DECLARE @periods                finance.period;
    DECLARE @json                   json;
    DECLARE this                    RECORD;
    DECLARE @balance                decimal(24, 4);
    DECLARE @is_periodic            bit = finance.is_periodic_inventory(@office_id);

    --We cannot divide by zero.
    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        @factor = 1;
    END;

    CREATE TABLE #cf_temp
    (
        item_id                     integer PRIMARY KEY,
        item                        national character varying(1000),
        account_master_id           integer,
        parent_item_id              integer REFERENCES #cf_temp(item_id),
        is_summation                bit DEFAULT(0),
        is_debit                    bit DEFAULT(0),
        is_sales                    bit DEFAULT(0),
        is_purchase                 bit DEFAULT(0)
    ) ;


    INSERT INTO @periods
    SELECT * FROM finance.get_periods(@date_from, @date_to);

    IF NOT EXISTS(SELECT * FROM @periods)
    BEGIN
        RAISERROR('Invalid period specified.', 10, 1);
    END;

    /**************************************************************************************************************************************************************************************
        CREATING PERIODS
    **************************************************************************************************************************************************************************************/
    SELECT string_agg(dynamic, '') FROM
    (
        SELECT 'ALTER TABLE #cf_temp ADD COLUMN "' + period_name + '" decimal(24, 4) DEFAULT(0);' as dynamic
        FROM @periods         
    ) periods
    INTO @sql;
    
    EXECUTE @sql;

    /**************************************************************************************************************************************************************************************
        CASHFLOW TABLE STRUCTURE START
    **************************************************************************************************************************************************************************************/
    INSERT INTO #cf_temp(item_id, item, is_summation, is_debit)
    SELECT  10000,  'Cash and cash equivalents, beginning of period',   0,  1    UNION ALL    
    SELECT  20000,  'Cash flows from operating activities',             1,   0   UNION ALL    
    SELECT  30000,  'Cash flows from investing activities',             1,   0   UNION ALL
    SELECT  40000,  'Cash flows from financing acticities',             1,   0   UNION ALL    
    SELECT  50000,  'Net increase in cash and cash equivalents',        0,  0   UNION ALL    
    SELECT  60000,  'Cash and cash equivalents, end of period',         0,  1;    

    INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, is_sales, is_purchase)
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 20000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'O' UNION ALL
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 30000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'I' UNION ALL 
    SELECT  cash_flow_heading_id,   cash_flow_heading_name, 40000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'F';

    INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, account_master_id)
    SELECT core.account_masters.account_master_id + 50000, core.account_masters.account_master_name,  core.cash_flow_setup.cash_flow_heading_id, core.cash_flow_headings.is_debit, core.account_masters.account_master_id
    FROM core.cash_flow_setup
    INNER JOIN core.account_masters
    ON core.cash_flow_setup.account_master_id = core.account_masters.account_master_id
    INNER JOIN core.cash_flow_headings
    ON core.cash_flow_setup.cash_flow_heading_id = core.cash_flow_headings.cash_flow_heading_id;

    /**************************************************************************************************************************************************************************************
        CASHFLOW TABLE STRUCTURE END
    **************************************************************************************************************************************************************************************/


    /**************************************************************************************************************************************************************************************
        ITERATING THROUGH PERIODS TO UPDATE TRANSACTION BALANCES
    **************************************************************************************************************************************************************************************/
    FOR this IN 
    SELECT * 
    FROM @periods 
    ORDER BY date_from ASC
    LOOP
        --
        --
        --Opening cash balance.
        --
        --
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
            (
                SELECT
                SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
                SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
            FROM finance.verified_cash_transaction_mat_view
            WHERE account_master_id IN(10101, 10102) 
            AND value_date <''' + CAST(this.date_from AS varchar(24)) +
            ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
            )
        WHERE #cf_temp.item_id = 10000;';

        EXECUTE @sql;

        --
        --
        --Updating debit balances of mapped account master heads.
        --
        --
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=tran.total_amount
        FROM
        (
            SELECT finance.verified_cash_transaction_mat_view.account_master_id,
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book NOT IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'', ''Purchase.Direct'', ''Purchase.Receipt'')
        AND account_master_id NOT IN(10101, 10102) 
        AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
        GROUP BY finance.verified_cash_transaction_mat_view.account_master_id
        ) AS tran
        WHERE tran.account_master_id = #cf_temp.account_master_id';
        EXECUTE @sql;

        --
        --
        --Updating cash paid to suppliers.
        --
        --
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
        
        (
            SELECT
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) 
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book IN (''Purchase.Direct'', ''Purchase.Receipt'', ''Purchase.Payment'')
        AND account_master_id NOT IN(10101, 10102) 
        AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
        )
        WHERE #cf_temp.is_purchase;';
        EXECUTE @sql;

        --
        --
        --Updating cash received from customers.
        --
        --
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
        
        (
            SELECT
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) 
        FROM finance.verified_cash_transaction_mat_view
        WHERE finance.verified_cash_transaction_mat_view.book IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'')
        AND account_master_id IN(10101, 10102) 
        AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
        )
        WHERE #cf_temp.is_sales;';
        PRINT @SQL;
        EXECUTE @sql;

        --Closing cash balance.
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"
        =
        (
            SELECT
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_cash_transaction_mat_view
        WHERE account_master_id IN(10101, 10102) 
        AND value_date <''' + CAST(this.date_to AS varchar(24)) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
        ) 
        WHERE #cf_temp.item_id = 60000;';

        EXECUTE @sql;

        --Reversing to debit balance for associated headings.
        @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"="' + this.period_name + '"*-1 WHERE is_debit= 1;';
        EXECUTE @sql;
    END LOOP;



    --Updating periodic balances on parent item by the sum of their respective child balances.
    SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"' + '=#cf_temp."' + period_name + '" + tran."' + period_name + '"'), ',') + 
    ' FROM 
    (
        SELECT parent_item_id, '
        + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') + '
         FROM #cf_temp
        GROUP BY parent_item_id
    ) 
    AS tran
        WHERE tran.parent_item_id = #cf_temp.item_id
        AND #cf_temp.item_id NOT IN (10000, 60000);'
    INTO @sql
    FROM @periods;

    PRINT @SQL;
    EXECUTE @sql;


    SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT
            #cf_temp.parent_item_id,'
        + array_to_string(array_agg('SUM(CASE is_debit WHEN 1 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    '
         FROM #cf_temp
         GROUP BY #cf_temp.parent_item_id
    ) 
    AS tran
    WHERE #cf_temp.item_id = tran.parent_item_id
    AND #cf_temp.parent_item_id IS NULL;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;


    --Dividing by the factor.
    SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"="' + period_name + '"/' + CAST(@factor AS varchar(100))), ',') + ';'
    INTO @sql
    FROM @periods;
    EXECUTE @sql;


    --Converting 0's to NULLS.
    SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"= CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'), ',') + ';'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;

    SELECT 
    'SELECT array_to_json(array_agg(row_to_json(report)))
    FROM
    (
        SELECT item, '
        + array_to_string(array_agg('"' + period_name + '"'), ',') +
        ', is_summation FROM #cf_temp
        WHERE account_master_id IS NULL
        ORDER BY item_id
    ) AS report;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql INTO @json ;

    SELECT @json;
END



GO


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
    @no_provison                    bit DEFAULT 0
)
RETURNS decimal(24, 4)
AS
BEGIN
    DECLARE @incomes                decimal(24, 4) = 0;
    DECLARE @expenses               decimal(24, 4) = 0;
    DECLARE @profit_before_tax      decimal(24, 4) = 0;
    DECLARE @tax_paid               decimal(24, 4) = 0;
    DECLARE @tax_provison           decimal(24, 4) = 0;

    SELECT SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    INTO @incomes
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id >=20100
    AND account_master_id <= 20300;
    
    SELECT SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    INTO @expenses
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id >=20400
    AND account_master_id <= 20701;
    
    SELECT SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END)
    INTO @tax_paid
    FROM finance.verified_transaction_mat_view
    WHERE value_date >= @date_from AND value_date <= @date_to
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
    AND account_master_id =20800;
    
    @profit_before_tax = COALESCE(@incomes, 0) - COALESCE(@expenses, 0);

    IF(@no_provison)
    BEGIN
        RETURN (@profit_before_tax - COALESCE(@tax_paid, 0)) / @factor;
    END;
    
    @tax_provison      = core.get_income_tax_provison_amount(@office_id, @profit_before_tax, COALESCE(@tax_paid, 0));
    
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
    @compact                        bit DEFAULT(1)
)
AS
BEGIN    
    DECLARE @sql                    national character varying(1000);
    DECLARE @periods                finance.period;
    DECLARE @json                   json;
    DECLARE this                    RECORD;
    DECLARE @balance                decimal(24, 4);
    DECLARE @is_periodic            bit = finance.is_periodic_inventory(@office_id);

    CREATE TABLE #pl_temp
    (
        item_id                     integer PRIMARY KEY,
        item                        national character varying(1000),
        account_id                  integer,
        parent_item_id              integer,
        is_profit                   bit DEFAULT(0),
        is_summation                bit DEFAULT(0),
        is_debit                    bit DEFAULT(0),
        amount                      decimal(24, 4) DEFAULT(0)
    );

    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        @factor = 1;
    END;

    INSERT INTO @periods
    SELECT * FROM finance.get_periods(@date_from, @date_to);

    IF NOT EXISTS(SELECT * FROM @periods)
    BEGIN
        RAISERROR('Invalid period specified.', 10, 1);
    END;

    SELECT string_agg(dynamic, '') FROM
    (
            SELECT 'ALTER TABLE #pl_temp ADD COLUMN "' + period_name + '" decimal(24, 4) DEFAULT(0);' as dynamic
            FROM @periods
         
    ) periods
    INTO @sql;
    
    EXECUTE @sql;

    --PL structure setup start
    INSERT INTO #pl_temp(item_id, item, is_summation, parent_item_id)
    SELECT 1000,   'Revenue',                      1,   NULL     UNION ALL
    SELECT 2000,   'Cost of Sales',                1,   NULL     UNION ALL
    SELECT 2001,   'Opening Stock',                0,  1000     UNION ALL
    SELECT 3000,   'Purchases',                    0,  1000     UNION ALL
    SELECT 4000,   'Closing Stock',                0,  1000     UNION ALL
    SELECT 5000,   'Direct Costs',                 1,   NULL     UNION ALL
    SELECT 6000,   'Gross Profit',                 0,  NULL     UNION ALL
    SELECT 7000,   'Operating Expenses',           1,   NULL     UNION ALL
    SELECT 8000,   'Operating Profit',             0,  NULL     UNION ALL
    SELECT 9000,   'Nonoperating Incomes',         1,   NULL     UNION ALL
    SELECT 10000,  'Financial Incomes',            1,   NULL     UNION ALL
    SELECT 11000,  'Financial Expenses',           1,   NULL     UNION ALL
    SELECT 11100,  'Interest Expenses',            1,   11000    UNION ALL
    SELECT 12000,  'Profit Before Income Taxes',   0,  NULL     UNION ALL
    SELECT 13000,  'Income Taxes',                 1,   NULL     UNION ALL
    SELECT 13001,  'Income Tax Provison',          0,  13000    UNION ALL
    SELECT 14000,  'Net Profit',                   1,   NULL;

    UPDATE #pl_temp SET is_debit = 1 WHERE item_id IN(2001, 3000, 4000);
    UPDATE #pl_temp SET is_profit = 1 WHERE item_id IN(6000,8000, 12000, 14000);
    
    INSERT INTO #pl_temp(item_id, account_id, item, parent_item_id, is_debit)
    SELECT id, account_id, account_name, 1000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20100, 1000) UNION ALL--Sales Accounts
    SELECT id, account_id, account_name, 2000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20400, 2001) UNION ALL--COGS Accounts
    SELECT id, account_id, account_name, 5000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20500, 5000) UNION ALL--Direct Cost
    SELECT id, account_id, account_name, 7000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20600, 7000) UNION ALL--Operating Expenses
    SELECT id, account_id, account_name, 9000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20200, 9000) UNION ALL--Nonoperating Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20300, 10000) UNION ALL--Financial Incomes
    SELECT id, account_id, account_name, 11000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20700, 11000) UNION ALL--Financial Expenses
    SELECT id, account_id, account_name, 11100 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20701, 11100) UNION ALL--Interest Expenses
    SELECT id, account_id, account_name, 13000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20800, 13001);--Income Tax Expenses

    IF(NOT @is_periodic)
    BEGIN
        DELETE FROM #pl_temp WHERE item_id IN(2001, 3000, 4000);
    END;
    --PL structure setup END;


    FOR this IN 
    SELECT * FROM @periods 
    ORDER BY date_from ASC
    LOOP
        --Updating credit balances of individual GL accounts.
        @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=tran.total_amount
        FROM
        (
            SELECT finance.verified_transaction_mat_view.account_id,
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_transaction_mat_view
        WHERE value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
        GROUP BY finance.verified_transaction_mat_view.account_id
        ) AS tran
        WHERE tran.account_id = #pl_temp.account_id';
        EXECUTE @sql;

        --Reversing to debit balance for expense headings.
        @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"="' + this.period_name + '"*-1 WHERE is_debit;';
        EXECUTE @sql;

        --Getting purchase and stock balances if this is a periodic inventory system.
        --In perpetual accounting system, one would not need to include these headings 
        --because the COGS A/C would be automatically updated on each transaction.
        IF(@is_periodic)
        BEGIN
            @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_closing_stock(''' + CAST(DATEADD(day,-1,this.date_from) AS varchar(24)) +  ''', ' + CAST(@office_id AS varchar(100)) + ') WHERE item_id=2001;';
            EXECUTE @sql;

            @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_purchase(''' + CAST(this.date_from AS varchar(24)) +  ''', ''' + CAST(this.date_to AS varchar(24)) + ''', ' + CAST(@office_id AS varchar(100)) + ') *-1 WHERE item_id=3000;';
            EXECUTE @sql;

            @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_closing_stock(''' + CAST(this.date_from AS varchar(24)) +  ''', ' + CAST(@office_id AS varchar(100)) + ') WHERE item_id=4000;';
            EXECUTE @sql;
        END;
    END LOOP;

    --Updating the column "amount" on each row by the sum of all periods.
    SELECT 'UPDATE #pl_temp SET amount = ' + array_to_string(array_agg('COALESCE("' + period_name + '", 0)'), ' +') + ';' INTO @sql
    FROM @periods;

    EXECUTE @sql;

    --Updating amount and periodic balances on parent item by the sum of their respective child balances.
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') + 
    ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, '
        + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') + '
         FROM #pl_temp
        GROUP BY parent_item_id
    ) 
    AS tran
        WHERE tran.parent_item_id = #pl_temp.item_id;'
    INTO @sql
    FROM @periods;
    EXECUTE @sql;

    --Updating Gross Profit.
    --Gross Profit = Revenue - (Cost of Sales + Direct Costs)
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 1000 THEN amount ELSE amount * -1 END) AS amount, '
        + array_to_string(array_agg('SUM(CASE item_id WHEN 1000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    '
         FROM #pl_temp
         WHERE item_id IN
         (
             1000,2000,5000
         )
    ) 
    AS tran
    WHERE item_id = 6000;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;


    --Updating Operating Profit.
    --Operating Profit = Gross Profit - Operating Expenses
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 6000 THEN amount ELSE amount * -1 END) AS amount, '
        + array_to_string(array_agg('SUM(CASE item_id WHEN 6000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    '
         FROM #pl_temp
         WHERE item_id IN
         (
             6000, 7000
         )
    ) 
    AS tran
    WHERE item_id = 8000;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;

    --Updating Profit Before Income Taxes.
    --Profit Before Income Taxes = Operating Profit + Nonoperating Incomes + Financial Incomes - Financial Expenses
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT
        SUM(CASE WHEN item_id IN(11000, 11100) THEN amount *-1 ELSE amount END) AS amount, '
        + array_to_string(array_agg('SUM(CASE WHEN item_id IN(11000, 11100) THEN "' + period_name + '"*-1  ELSE "' + period_name + '" END) AS "' + period_name + '"'), ',') +
    '
         FROM #pl_temp
         WHERE item_id IN
         (
             8000, 9000, 10000, 11000, 11100
         )
    ) 
    AS tran
    WHERE item_id = 12000;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;

    --Updating Income Tax Provison.
    --Income Tax Provison = Profit Before Income Taxes * Income Tax Rate - Paid Income Taxes
    SELECT * INTO this FROM #pl_temp WHERE item_id = 12000;
    
    @sql = 'UPDATE #pl_temp SET amount = core.get_income_tax_provison_amount(' + CAST(@office_id AS varchar(100)) + ',' + CAST(this.amount AS varchar(100)) + ',(SELECT amount FROM #pl_temp WHERE item_id = 13000)), ' 
    + array_to_string(array_agg('"' + period_name + '"=core.get_income_tax_provison_amount(' + CAST(@office_id varchar(100)) + ',' + core.get_field(hstore(this.*), period_name) + ', (SELECT "' + period_name + '" FROM #pl_temp WHERE item_id = 13000))'), ',')
            + ' WHERE item_id = 13001;'
    FROM @periods;

    EXECUTE @sql;

    --Updating amount and periodic balances on parent item by the sum of their respective child balances, once again to add the Income Tax Provison to Income Tax Expenses.
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, '
        + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') +
    '
         FROM #pl_temp
        GROUP BY parent_item_id
    ) 
    AS tran
        WHERE tran.parent_item_id = #pl_temp.item_id;'
    INTO @sql
    FROM @periods;
    EXECUTE @sql;


    --Updating Net Profit.
    --Net Profit = Profit Before Income Taxes - Income Tax Expenses
    SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    + ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 13000 THEN amount *-1 ELSE amount END) AS amount, '
        + array_to_string(array_agg('SUM(CASE item_id WHEN 13000 THEN "' + period_name + '"*-1  ELSE "' + period_name + '" END) AS "' + period_name + '"'), ',') +
    '
         FROM #pl_temp
         WHERE item_id IN
         (
             12000, 13000
         )
    ) 
    AS tran
    WHERE item_id = 14000;'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;

    --Removing ledgers having zero balances
    DELETE FROM #pl_temp
    WHERE COALESCE(amount, 0) = 0
    AND account_id IS NOT NULL;


    --Dividing by the factor.
    SELECT 'UPDATE #pl_temp SET amount = amount /' + CAST(@factor varchar(100)) + ',' + array_to_string(array_agg('"' + period_name + '"="' + period_name + '"/' + CAST(@factor varchar(100))), ',') + ';'
    INTO @sql
    FROM @periods;
    EXECUTE @sql;


    --Converting 0's to NULLS.
    SELECT 'UPDATE #pl_temp SET amount = CASE WHEN amount = 0 THEN NULL ELSE amount END,' + array_to_string(array_agg('"' + period_name + '"= CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'), ',') + ';'
    INTO @sql
    FROM @periods;

    EXECUTE @sql;

    IF(@compact)
    BEGIN
        SELECT array_to_json(array_agg(row_to_json(report)))
        INTO @json
        FROM
        (
            SELECT item, amount, is_profit, is_summation
            FROM #pl_temp
            ORDER BY item_id
        ) AS report;
    END
    ELSE
    BEGIN
        SELECT 
        'SELECT array_to_json(array_agg(row_to_json(report)))
        FROM
        (
            SELECT item, amount,'
            + array_to_string(array_agg('"' + period_name + '"'), ',') +
            ', is_profit, is_summation FROM #pl_temp
            ORDER BY item_id
        ) AS report;'
        INTO @sql
        FROM @periods;

        EXECUTE @sql INTO @json ;
    END;    

    SELECT @json;
END



GO


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
RETURNS decimal(24, 4)
AS
BEGIN
    DECLARE     @date_from              date;
    DECLARE     @net_profit             decimal(24, 4);
    DECLARE     @paid_dividends         decimal(24, 4);

    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        @factor = 1;
    END;
    
    @date_from              = finance.get_fiscal_year_start_date(@office_id);    
    @net_profit             = finance.get_net_profit(@date_from, @date_to, @office_id, @factor, 1);

    SELECT 
        COALESCE(SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) / @factor, 0)
    INTO 
        @paid_dividends
    FROM finance.verified_transaction_mat_view
    WHERE value_date <=_date_to
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
    @factor                         decimal(24, 4),
    @change_side_when_negative      bit DEFAULT(1),
    @include_zero_balance_accounts  bit DEFAULT(1)
)
RETURNS @result TABLE
(
    id                      integer,
    account_id              integer,
    account_number          national character varying(24),
    account                 national character varying(1000),
    previous_debit          decimal(24, 4),
    previous_credit         decimal(24, 4),
    debit                   decimal(24, 4),
    credit                  decimal(24, 4),
    closing_debit           decimal(24, 4),
    closing_credit          decimal(24, 4)
)
AS

BEGIN
    IF(@date_from IS NULL)
    BEGIN
        RAISERROR('Invalid date.', 10, 1);
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
        RAISERROR('Cannot produce trial balance of office(s) having different base currencies.', 10, 1);
    END;

    DECLARE @trial_balance TABLE
    (
        id                      integer,
        account_id              integer,
        account_number national character varying(24),
        account                 national character varying(1000),
        previous_debit          decimal(24, 4),
        previous_credit         decimal(24, 4),
        debit                   decimal(24, 4),
        credit                  decimal(24, 4),
        closing_debit           decimal(24, 4),
        closing_credit          decimal(24, 4),
        root_account_id         integer,
        normally_debit          bit
    );

    DECLARE @summary_trial_balance TABLE
    (
        id                      integer,
        account_id              integer,
        account_number national character varying(24),
        account                 national character varying(1000),
        previous_debit          decimal(24, 4),
        previous_credit         decimal(24, 4),
        debit                   decimal(24, 4),
        credit                  decimal(24, 4),
        closing_debit           decimal(24, 4),
        closing_credit          decimal(24, 4),
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

    UPDATE @trial_balance SET root_account_id = finance.get_root_account_id(account_id);

        
    IF(@compact)
    BEGIN
        INSERT INTO @summary_trial_balance
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
        INSERT INTO @summary_trial_balance
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
    
    UPDATE @summary_trial_balance SET
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name,
        normally_debit = finance.account_masters.normally_debit
    FROM finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
    WHERE account_id = finance.accounts.account_id;

    UPDATE @summary_trial_balance SET 
        closing_debit = COALESCE(previous_debit, 0) + COALESCE(debit, 0),
        closing_credit = COALESCE(previous_credit, 0) + COALESCE(credit, 0);
        


     UPDATE @summary_trial_balance SET previous_debit = COALESCE(previous_debit, 0) - COALESCE(previous_credit, 0), previous_credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET previous_credit = COALESCE(previous_credit, 0) - COALESCE(previous_debit, 0), previous_debit = NULL WHERE normally_debit = 0;
 
     UPDATE @summary_trial_balance SET debit = COALESCE(debit, 0) - COALESCE(credit, 0), credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET credit = COALESCE(credit, 0) - COALESCE(debit, 0), debit = NULL WHERE normally_debit = 0;
 
     UPDATE @summary_trial_balance SET closing_debit = COALESCE(closing_debit, 0) - COALESCE(closing_credit, 0), closing_credit = NULL WHERE normally_debit = 1;
     UPDATE @summary_trial_balance SET closing_credit = COALESCE(closing_credit, 0) - COALESCE(closing_debit, 0), closing_debit = NULL WHERE normally_debit = 0;


    IF(NOT @include_zero_balance_accounts)
    BEGIN
        DELETE FROM @summary_trial_balance WHERE COALESCE(closing_debit) + COALESCE(closing_credit) = 0;
    END;
    
    IF(@factor > 0)
    BEGIN
        UPDATE @summary_trial_balance SET previous_debit   = previous_debit/_factor;
        UPDATE @summary_trial_balance SET previous_credit  = previous_credit/_factor;
        UPDATE @summary_trial_balance SET debit            = debit/_factor;
        UPDATE @summary_trial_balance SET credit           = credit/_factor;
        UPDATE @summary_trial_balance SET closing_debit    = closing_debit/_factor;
        UPDATE @summary_trial_balance SET closing_credit   = closing_credit/_factor;
    END;

    --Remove Zeros
    UPDATE @summary_trial_balance SET previous_debit = NULL WHERE previous_debit = 0;
    UPDATE @summary_trial_balance SET previous_credit = NULL WHERE previous_credit = 0;
    UPDATE @summary_trial_balance SET debit = NULL WHERE debit = 0;
    UPDATE @summary_trial_balance SET credit = NULL WHERE credit = 0;
    UPDATE @summary_trial_balance SET closing_debit = NULL WHERE closing_debit = 0;
    UPDATE @summary_trial_balance SET closing_debit = NULL WHERE closing_credit = 0;

    IF(@change_side_when_negative)
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
    FROM temp_trial_balance2;

    RETURN;
END



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
    WHERE app_name = 'Finance'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'Finance'
);

DELETE FROM core.menus
WHERE app_name = 'Finance';


EXECUTE core.create_app 'Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/tasks/journal/entry', NULL;

EXECUTE core.create_menu 'Finance', 'Tasks', '', 'lightning', '';
EXECUTE core.create_menu 'Finance', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'add square', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'exchange', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Verification Policy', '/dashboard/finance/tasks/verification-policy', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Auto Verification Policy', '/dashboard/finance/tasks/verification-policy/auto', 'check circle', 'Tasks';
EXECUTE core.create_menu 'Finance', 'EOD Processing', '/dashboard/finance/tasks/eod-processing', 'spinner', 'Tasks';

EXECUTE core.create_menu 'Finance', 'Setup', 'square outline', 'configure', '';
EXECUTE core.create_menu 'Finance', 'Chart of Account', '/dashboard/finance/setup/chart-of-accounts', 'sitemap', 'Setup';
EXECUTE core.create_menu 'Finance', 'Currencies', '/dashboard/finance/setup/currencies', 'dollar', 'Setup';
EXECUTE core.create_menu 'Finance', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'university', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'book', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'edit', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'closed captioning', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'bookmark', 'Setup';

EXECUTE core.create_menu 'Finance', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'Finance', 'Account Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/AccountStatement.xml', 'file national character varying(1000) outline', 'Reports';
EXECUTE core.create_menu 'Finance', 'Trial Balance', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TrialBalance.xml', 'signal', 'Reports';
EXECUTE core.create_menu 'Finance', 'Profit & Loss Account', '/dashboard/finance/reports/pl-account', 'line chart', 'Reports';
EXECUTE core.create_menu 'Finance', 'Retained Earnings Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/RetainedEarnings.xml', 'arrow circle down', 'Reports';
EXECUTE core.create_menu 'Finance', 'Balance Sheet', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/BalanceSheet.xml', 'calculator', 'Reports';
EXECUTE core.create_menu 'Finance', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'crosshairs', 'Reports';
EXECUTE core.create_menu 'Finance', 'Exchange Rate Report', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/ExchangeRates.xml', 'options', 'Reports';


DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'Finance',
'{*}';



GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.account_scrud_view.sql --<--<--
IF OBJECT_ID('finance.account_scrud_view CASCADE') IS NOT NULL
DROP VIEW finance.account_scrud_view CASCADE;

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
    account.get_name_by_user_id(finance.auto_verification_policy.user_id) AS user,
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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.scrud-views/finance.journal_verification_policy_scrud_view.sql --<--<--
IF OBJECT_ID('finance.journal_verification_policy_scrud_view') IS NOT NULL
DROP VIEW finance.journal_verification_policy_scrud_view;

GO




CREATE VIEW finance.journal_verification_policy_scrud_view
AS
SELECT
    finance.journal_verification_policy.journal_verification_policy_id,
    finance.journal_verification_policy.user_id,
    account.get_name_by_user_id(finance.journal_verification_policy.user_id) AS user,
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
IF OBJECT_ID('finance.merchant_fee_setup_scrud_view CASCADE') IS NOT NULL
DROP VIEW finance.merchant_fee_setup_scrud_view CASCADE;

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
WHERE account_master_id = 10102
ORDER BY account_id;


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
WHERE account_master_id = 15010
ORDER BY account_id;


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
WHERE account_master_id = 10110
ORDER BY account_id;



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
IF OBJECT_ID('finance.verified_transaction_view CASCADE') IS NOT NULL
DROP VIEW finance.verified_transaction_view CASCADE;

GO



CREATE VIEW finance.verified_transaction_view
AS
SELECT * FROM finance.transaction_view
WHERE verification_status_id > 0;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/2.finance.verified_transaction_mat_view.sql --<--<--
DROP MATERIALIZED VIEW IF EXISTS finance.verified_transaction_mat_view CASCADE;

CREATE MATERIALIZED VIEW finance.verified_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_view;

ALTER MATERIALIZED VIEW finance.verified_transaction_mat_view
OWNER TO frapid_db_user;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/3. finance.verified_cash_transaction_mat_view.sql --<--<--
DROP MATERIALIZED VIEW IF EXISTS finance.verified_cash_transaction_mat_view;

CREATE MATERIALIZED VIEW finance.verified_cash_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_mat_view
WHERE finance.verified_transaction_mat_view.transaction_master_id
IN
(
    SELECT finance.verified_transaction_mat_view.transaction_master_id 
    FROM finance.verified_transaction_mat_view
    WHERE account_master_id IN(10101, 10102) --Cash and Bank A/C
);

ALTER MATERIALIZED VIEW finance.verified_cash_transaction_mat_view
OWNER TO frapid_db_user;


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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/05.views/finance.trial_balance_view.sql --<--<--
DROP MATERIALIZED VIEW IF EXISTS finance.trial_balance_view;
CREATE MATERIALIZED VIEW finance.trial_balance_view
AS
SELECT finance.get_account_name_by_account_id(account_id), 
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE NULL END) AS debit,
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE NULL END) AS Credit
FROM finance.verified_transaction_view
GROUP BY account_id;

ALTER MATERIALIZED VIEW finance.trial_balance_view
OWNER TO frapid_db_user;


GO


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/99.ownership.sql --<--<--
EXEC sp_addrolemember  @rolename = 'db_owner', @membername  = 'frapid_db_user'


EXEC sp_addrolemember  @rolename = 'db_datareader', @membername  = 'report_user'


GO

