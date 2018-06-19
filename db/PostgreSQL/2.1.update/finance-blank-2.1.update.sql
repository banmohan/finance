-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/01.types-domains-tables-and-constraints/tables-and-constraints.sql --<--<--
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


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.can_post_transaction.sql --<--<--
DROP FUNCTION IF EXISTS finance.can_post_transaction(_login_id bigint, _user_id integer, _office_id integer, transaction_book text, _value_date date);
DROP FUNCTION IF EXISTS finance.can_post_transaction(_login_id bigint, _user_id integer, _office_id integer, transaction_book text, _value_date timestamp);

CREATE FUNCTION finance.can_post_transaction(_login_id bigint, _user_id integer, _office_id integer, transaction_book text, _value_date date)
RETURNS bool
AS
$$
    DECLARE _eod_required                       boolean := finance.eod_required(_office_id);
    DECLARE _fiscal_year_start_date             date    := finance.get_fiscal_year_start_date(_office_id);
    DECLARE _fiscal_year_end_date               date    := finance.get_fiscal_year_end_date(_office_id);
BEGIN
	IF(_value_date IS NULL) THEN
		RAISE EXCEPTION 'Invalid value date'
        USING ERRCODE='P3101';
	END IF;
	
	
    IF(account.is_valid_login_id(_login_id) = false) THEN
        RAISE EXCEPTION 'Invalid LoginId.'
        USING ERRCODE='P3101';
    END IF; 

    IF(core.is_valid_office_id(_office_id) = false) THEN
        RAISE EXCEPTION 'Invalid OfficeId.'
        USING ERRCODE='P3010';
    END IF;

    IF(finance.is_transaction_restricted(_office_id)) THEN
        RAISE EXCEPTION 'This establishment does not allow transaction posting.'
        USING ERRCODE='P5100';
    END IF;
    
    IF(_eod_required) THEN
        IF(finance.is_restricted_mode()) THEN
            RAISE EXCEPTION 'Cannot post transaction during restricted transaction mode.'
            USING ERRCODE='P5101';
        END IF;

        IF(_value_date < finance.get_value_date(_office_id)) THEN
            RAISE EXCEPTION 'Past dated transactions are not allowed.'
            USING ERRCODE='P5010';
        END IF;
    END IF;

    IF(_value_date < _fiscal_year_start_date) THEN
        RAISE EXCEPTION 'You cannot post transactions before the current fiscal year start date. Value date: %, Fiscal Year Start Date: %.', _value_date, _fiscal_year_start_date
        USING ERRCODE='P5010';
    END IF;

    IF(_value_date > _fiscal_year_end_date) THEN
        RAISE EXCEPTION 'You cannot post transactions after the current fiscal year end date. Value date: %, Fiscal Year End Date: %.', _value_date, _fiscal_year_end_date
        USING ERRCODE='P5010';
    END IF;
    
    IF NOT EXISTS 
    (
        SELECT *
        FROM account.users
        INNER JOIN account.roles
        ON account.users.role_id = account.roles.role_id
        AND user_id = _user_id
    ) THEN
        RAISE EXCEPTION 'Access is denied. You are not authorized to post this transaction.'
        USING ERRCODE='P9010';        
    END IF;

    RETURN true;
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION finance.can_post_transaction(_login_id bigint, _user_id integer, _office_id integer, transaction_book text, _value_date timestamp)
RETURNS bool
AS
$$
BEGIN
    RETURN finance.can_post_transaction(_login_id, _user_id, _office_id, transaction_book, _value_date::date);
END
$$
LANGUAGE plpgsql;

--SELECT finance.can_post_transaction(1, 1, 1, 'Sales', '1-1-2020');

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_account_statement.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_account_statement
(
    _date_from        		date,
    _date_to          		date,
    _user_id                integer,
    _account_id             integer,
    _office_id              integer
);

DROP FUNCTION IF EXISTS finance.get_account_statement
(
    _date_from        		date,
    _date_to          		date,
    _user_id                integer,
    _account_id             integer,
    _office_id              integer,
    _dont_include_children	boolean
);


CREATE FUNCTION finance.get_account_statement
(
    _date_from        		date,
    _date_to          		date,
    _user_id                integer,
    _account_id             integer,
    _office_id              integer,
    _dont_include_children	boolean = false
)
RETURNS TABLE
(
    id                      integer,
	transaction_id	        bigint,
	transaction_detail_id	bigint,
    value_date              date,
    book_date               date,
    tran_code               text,
    reference_number        text,
    statement_reference     text,
    reconciliation_memo     text,
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    balance                 numeric(30, 6),
    office                  text,
    book                    text,
    account_id              integer,
    account_number          text,
    account                 text,
    posted_on               TIMESTAMP WITH TIME ZONE,
    posted_by               text,
    approved_by             text,
    verification_status     integer
)
AS
$$
    DECLARE _normally_debit boolean;
BEGIN
    _normally_debit             := finance.is_normally_debit(_account_id);

	DROP TABLE IF EXISTS temp_account_ids;
	CREATE TEMPORARY TABLE temp_account_ids
	(
		account_id				integer
	) ON COMMIT DROP;

	IF(NOT _dont_include_children) THEN
		INSERT INTO temp_account_ids
		SELECT * FROM finance.get_account_ids(_account_id);
	ELSE
		INSERT INTO temp_account_ids
		SELECT _account_id;
	END IF;

    DROP TABLE IF EXISTS temp_account_statement;
    CREATE TEMPORARY TABLE temp_account_statement
    (
        id                      SERIAL,
        transaction_id	        bigint,
		transaction_detail_id	bigint,
        value_date              date,
        book_date               date,
        tran_code               text,
        reference_number        text,
        statement_reference     text,
		reconciliation_memo		text,
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        balance                 numeric(30, 6),
        office                  text,
        book                    text,
        account_id              integer,
        account_number          text,
        account                 text,
        posted_on               TIMESTAMP WITH TIME ZONE,
        posted_by               text,
        approved_by             text,
        verification_status     integer
    ) ON COMMIT DROP;


    INSERT INTO temp_account_statement(value_date, book_date, tran_code, reference_number, statement_reference, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
        _date_from,
        _date_from,
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
    AND finance.transaction_master.book_date < _date_from
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM temp_account_ids)
    AND NOT finance.transaction_master.deleted;

    DELETE FROM temp_account_statement
    WHERE COALESCE(temp_account_statement.debit, 0) = 0
    AND COALESCE(temp_account_statement.credit, 0) = 0;
    

    UPDATE temp_account_statement SET 
    debit = temp_account_statement.credit * -1,
    credit = 0
    WHERE temp_account_statement.credit < 0;
    

    INSERT INTO temp_account_statement(transaction_id, transaction_detail_id, value_date, book_date, tran_code, reference_number, statement_reference, reconciliation_memo, debit, credit, office, book, account_id, posted_on, posted_by, approved_by, verification_status)
    SELECT
		finance.transaction_details.transaction_master_id,
		finance.transaction_details.transaction_detail_id,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master. transaction_code,
        finance.transaction_master.reference_number::text,
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
    AND finance.transaction_master.book_date >= _date_from
    AND finance.transaction_master.book_date <= _date_to
    AND finance.transaction_master.office_id IN (SELECT * FROM core.get_office_ids(_office_id)) 
    AND finance.transaction_details.account_id IN (SELECT * FROM temp_account_ids)
    AND NOT finance.transaction_master.deleted
    ORDER BY 
        finance.transaction_master.value_date,
        finance.transaction_master.transaction_ts,
        finance.transaction_master.book_date,
        finance.transaction_master.last_verified_on;



    UPDATE temp_account_statement
    SET balance = c.balance
    FROM
    (
        SELECT
            temp_account_statement.id, 
            SUM(COALESCE(c.credit, 0)) 
            - 
            SUM(COALESCE(c.debit,0)) As balance
        FROM temp_account_statement
        LEFT JOIN temp_account_statement AS c 
            ON (c.id <= temp_account_statement.id)
        GROUP BY temp_account_statement.id
        ORDER BY temp_account_statement.id
    ) AS c
    WHERE temp_account_statement.id = c.id;


    UPDATE temp_account_statement SET 
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name
    FROM finance.accounts
    WHERE temp_account_statement.account_id = finance.accounts.account_id;


    IF(_normally_debit) THEN
        UPDATE temp_account_statement SET balance = temp_account_statement.balance * -1;
    END IF;

    RETURN QUERY
    SELECT * FROM temp_account_statement;
END;
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_cash_repository_balance.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_cash_repository_balance(_cash_repository_id integer, _currency_code national character varying(12));

CREATE FUNCTION finance.get_cash_repository_balance(_cash_repository_id integer, _currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
$$
    DECLARE _debit public.money_strict2;
    DECLARE _credit public.money_strict2;
BEGIN
    SELECT COALESCE(SUM(amount_in_currency), 0::public.money_strict2) INTO _debit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=$1
    AND currency_code=$2
    AND tran_type='Dr';

    SELECT COALESCE(SUM(amount_in_currency), 0::public.money_strict2) INTO _credit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=$1
    AND currency_code=$2
    AND tran_type='Cr';

    RETURN _debit - _credit;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_journal_view.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_journal_view
(
    _user_id                        integer,
    _office_id                      integer,
    _from                           date,
    _to                             date,
    _tran_id                        bigint,
    _tran_code                      national character varying(50),
    _book                           national character varying(50),
    _reference_number               national character varying(50),
    _statement_reference            national character varying(50),
    _posted_by                      national character varying(50),
    _office                         national character varying(50),
    _status                         national character varying(12),
    _verified_by                    national character varying(50),
    _reason                         national character varying(128)
);

DROP FUNCTION IF EXISTS finance.get_journal_view
(
    _user_id                        integer,
    _office_id                      integer,
    _from                           date,
    _to                             date,
    _tran_id                        bigint,
    _tran_code                      national character varying(50),
    _book                           national character varying(50),
    _reference_number               national character varying(50),
    _amount							numeric(30, 6),	
    _statement_reference            national character varying(50),
    _posted_by                      national character varying(50),
    _office                         national character varying(50),
    _status                         national character varying(12),
    _verified_by                    national character varying(50),
    _reason                         national character varying(128)
);

CREATE FUNCTION finance.get_journal_view
(
    _user_id                        integer,
    _office_id                      integer,
    _from                           date,
    _to                             date,
    _tran_id                        bigint,
    _tran_code                      national character varying(50),
    _book                           national character varying(50),
    _reference_number               national character varying(50),
	_amount							numeric(30, 6),
    _statement_reference            national character varying(50),
    _posted_by                      national character varying(50),
    _office                         national character varying(50),
    _status                         national character varying(12),
    _verified_by                    national character varying(50),
    _reason                         national character varying(128)
)
RETURNS TABLE
(
    transaction_master_id           bigint,
    transaction_code                text,
    book                            text,
    value_date                      date,
    book_date                      	date,
    reference_number                text,
    amount							numeric(30, 6),
    statement_reference             text,
    posted_by                       text,
    office                          text,
    status                          text,
    verified_by                     text,
    verified_on                     TIMESTAMP WITH TIME ZONE,
    reason                          text,
    transaction_ts                  TIMESTAMP WITH TIME ZONE
)
AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE office_cte(office_id) AS 
    (
        SELECT _office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    SELECT 
        finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code::text,
        finance.transaction_master.book::text,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number::text,
		SUM
		(
			CASE WHEN finance.transaction_details.tran_type = 'Cr' THEN 1 ELSE 0 END 
				* 
			finance.transaction_details.amount_in_local_currency
		),
        finance.transaction_master.statement_reference::text,
        account.get_name_by_user_id(finance.transaction_master.user_id)::text as posted_by,
        core.get_office_name_by_office_id(finance.transaction_master.office_id)::text as office,
        finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id)::text as status,
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id)::text as verified_by,
        finance.transaction_master.last_verified_on AS verified_on,
        finance.transaction_master.verification_reason::text AS reason,    
        finance.transaction_master.transaction_ts
    FROM finance.transaction_master
	INNER JOIN finance.transaction_details
	ON finance.transaction_details.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE 1 = 1
    AND finance.transaction_master.value_date BETWEEN _from AND _to
    AND finance.transaction_master.office_id IN (SELECT office_id FROM office_cte)
    AND (_tran_id = 0 OR _tran_id  = finance.transaction_master.transaction_master_id)
    AND LOWER(finance.transaction_master.transaction_code) LIKE '%' || LOWER(_tran_code) || '%' 
    AND LOWER(finance.transaction_master.book) LIKE '%' || LOWER(_book) || '%' 
    AND COALESCE(LOWER(finance.transaction_master.reference_number), '') LIKE '%' || LOWER(_reference_number) || '%' 
    AND COALESCE(LOWER(finance.transaction_master.statement_reference), '') LIKE '%' || LOWER(_statement_reference) || '%' 
    AND COALESCE(LOWER(finance.transaction_master.verification_reason), '') LIKE '%' || LOWER(_reason) || '%' 
    AND LOWER(account.get_name_by_user_id(finance.transaction_master.user_id)) LIKE '%' || LOWER(_posted_by) || '%' 
    AND LOWER(core.get_office_name_by_office_id(finance.transaction_master.office_id)) LIKE '%' || LOWER(_office) || '%' 
    AND COALESCE(LOWER(finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id)), '') LIKE '%' || LOWER(_status) || '%' 
    AND COALESCE(LOWER(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id)), '') LIKE '%' || LOWER(_verified_by) || '%'    
    AND NOT finance.transaction_master.deleted
    GROUP BY 
		finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code,
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number,
		finance.transaction_master.statement_reference,
		finance.transaction_master.last_verified_on,
        finance.transaction_master.verification_reason,    
        finance.transaction_master.transaction_ts,
		finance.transaction_master.verified_by_user_id,
		finance.transaction_master.user_id,
		finance.transaction_master.office_id,
		finance.transaction_master.verification_status_id
	HAVING SUM
		(
			CASE WHEN finance.transaction_details.tran_type = 'Cr' THEN 1 ELSE 0 END 
				* 
			finance.transaction_details.amount_in_local_currency
		) = _amount
		OR _amount = 0
    ORDER BY value_date ASC, verification_status_id DESC;
END
$$
LANGUAGE plpgsql;

-- 
-- SELECT * FROM finance.get_journal_view
-- (
--     1,
--     1,
--     '1-1-2000',
--     '1-1-2020',
--     0,
--     '',
--     '',
--     '',
-- 	0,
--     '',
--     '',
--     '',
--     '',
--     '',
--     ''
-- );

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_new_transaction_counter.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_new_transaction_counter(date);

CREATE FUNCTION finance.get_new_transaction_counter(date)
RETURNS integer
AS
$$
    DECLARE _ret_val integer;
BEGIN
    SELECT INTO _ret_val
        COALESCE(MAX(transaction_counter),0)
    FROM finance.transaction_master
    WHERE finance.transaction_master.value_date=$1;

    IF _ret_val IS NULL THEN
        RETURN 1::integer;
    ELSE
        RETURN (_ret_val + 1)::integer;
    END IF;
END;
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_profit_and_loss_statement.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_profit_and_loss_statement
(
    _date_from                      date,
    _date_to                        date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer,
    _compact                        boolean
);

CREATE FUNCTION finance.get_profit_and_loss_statement
(
    _date_from                      date,
    _date_to                        date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer,
    _compact                        boolean DEFAULT(true)
)
RETURNS json
AS
$$
    DECLARE _sql                    text;
    DECLARE _periods                finance.period[];
    DECLARE _json                   json;
    DECLARE this                    RECORD;
    DECLARE _balance                numeric(30, 6);
    DECLARE _is_periodic            boolean = inventory.is_periodic_inventory(_office_id);
BEGIN    
    DROP TABLE IF EXISTS pl_temp;
    CREATE TEMPORARY TABLE pl_temp
    (
        item_id                     integer PRIMARY KEY,
        item                        text,
        account_id                  integer,
        parent_item_id              integer REFERENCES pl_temp(item_id),
        is_profit                   boolean DEFAULT(false),
        is_summation                boolean DEFAULT(false),
        is_debit                    boolean DEFAULT(false),
        amount                      numeric(30, 6) DEFAULT(0)
    ) ON COMMIT DROP;

    IF(COALESCE(_factor, 0) = 0) THEN
        _factor := 1;
    END IF;

    _periods            := finance.get_periods(_date_from, _date_to);

    IF(_periods IS NULL) THEN
        RAISE EXCEPTION 'Invalid period specified.'
        USING ERRCODE='P3009';
    END IF;

    SELECT string_agg(dynamic, '') FROM
    (
            SELECT 'ALTER TABLE pl_temp ADD COLUMN "' || period_name || '" numeric(30, 6) DEFAULT(0);' as dynamic
            FROM explode_array(_periods)
         
    ) periods
    INTO _sql;
    
    EXECUTE _sql;

    --PL structure setup start
    INSERT INTO pl_temp(item_id, item, is_summation, parent_item_id)
    SELECT 1000,   'Revenue',                      true,   NULL::integer   UNION ALL
    SELECT 2000,   'Cost of Sales',                true,   NULL::integer   UNION ALL
    SELECT 2001,   'Opening Stock',                false,  1000            UNION ALL
    SELECT 3000,   'Purchases',                    false,  1000            UNION ALL
    SELECT 4000,   'Closing Stock',                false,  1000            UNION ALL
    SELECT 5000,   'Direct Costs',                 true,   NULL::integer   UNION ALL
    SELECT 6000,   'Gross Profit',                 false,  NULL::integer   UNION ALL
    SELECT 7000,   'Operating Expenses',           true,   NULL::integer   UNION ALL
    SELECT 8000,   'Operating Profit',             false,  NULL::integer   UNION ALL
    SELECT 9000,   'Nonoperating Incomes',         true,   NULL::integer   UNION ALL
    SELECT 10000,  'Financial Incomes',            true,   NULL::integer   UNION ALL
    SELECT 11000,  'Financial Expenses',           true,   NULL::integer   UNION ALL
    SELECT 11100,  'Interest Expenses',            true,   11000           UNION ALL
    SELECT 12000,  'Profit Before Income Taxes',   false,  NULL::integer   UNION ALL
    SELECT 13000,  'Income Taxes',                 true,   NULL::integer   UNION ALL
    SELECT 13001,  'Income Tax Provison',          false,  13000            UNION ALL
    SELECT 14000,  'Net Profit',                   true,   NULL::integer;

    UPDATE pl_temp SET is_debit = true WHERE item_id IN(2001, 3000, 4000);
    UPDATE pl_temp SET is_profit = true WHERE item_id IN(6000,8000, 12000, 14000);
    
    INSERT INTO pl_temp(item_id, account_id, item, parent_item_id, is_debit)
    SELECT id, account_id, account_name, 1000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20100, 1000) UNION ALL--Sales Accounts
    SELECT id, account_id, account_name, 2000 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20400, 2001) UNION ALL--COGS Accounts
    SELECT id, account_id, account_name, 5000 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20500, 5000) UNION ALL--Direct Cost
    SELECT id, account_id, account_name, 7000 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20600, 7000) UNION ALL--Operating Expenses
    SELECT id, account_id, account_name, 9000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20200, 9000) UNION ALL--Nonoperating Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20300, 10000) UNION ALL--Financial Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20301, 10100) UNION ALL--Dividends Received
    SELECT id, account_id, account_name, 10000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20302, 10200) UNION ALL--Interest Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20310, 10300) UNION ALL--Commission Incomes
    SELECT id, account_id, account_name, 10000 as parent_item_id, false as is_debit FROM finance.get_account_view_by_account_master_id(20350, 10400) UNION ALL--Other Incomes
    SELECT id, account_id, account_name, 11000 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20700, 11000) UNION ALL--Financial Expenses
    SELECT id, account_id, account_name, 11100 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20701, 11100) UNION ALL--Interest Expenses
    SELECT id, account_id, account_name, 11100 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20710, 11200) UNION ALL--Other Expenses
    SELECT id, account_id, account_name, 13000 as parent_item_id, true as is_debit FROM finance.get_account_view_by_account_master_id(20800, 13001);--Income Tax Expenses

    IF(NOT _is_periodic) THEN
        DELETE FROM pl_temp WHERE item_id IN(2001, 3000, 4000);
    END IF;
    --PL structure setup end


    FOR this IN SELECT * FROM explode_array(_periods) ORDER BY date_from ASC
    LOOP
        --Updating credit balances of individual GL accounts.
        _sql := 'UPDATE pl_temp SET "' || this.period_name || '"=tran.total_amount
        FROM
        (
            SELECT finance.verified_transaction_mat_view.account_id,
            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
        FROM finance.verified_transaction_mat_view
        WHERE value_date >=''' || this.date_from::text || ''' AND value_date <=''' || this.date_to::text ||
        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' || _office_id::text || '))
        GROUP BY finance.verified_transaction_mat_view.account_id
        ) AS tran
        WHERE tran.account_id = pl_temp.account_id';
        EXECUTE _sql;

        --Reversing to debit balance for expense headings.
        _sql := 'UPDATE pl_temp SET "' || this.period_name || '"="' || this.period_name || '"*-1 WHERE is_debit;';
        EXECUTE _sql;

        --Getting purchase and stock balances if this is a periodic inventory system.
        --In perpetual accounting system, one would not need to include these headings 
        --because the COGS A/C would be automatically updated on each transaction.
        IF(_is_periodic) THEN
            _sql := 'UPDATE pl_temp SET "' || this.period_name || '"=transactions.get_closing_stock(''' || (this.date_from::TIMESTAMP - INTERVAL '1 day')::text ||  ''', ' || _office_id::text || ') WHERE item_id=2001;';
            EXECUTE _sql;

            _sql := 'UPDATE pl_temp SET "' || this.period_name || '"=transactions.get_purchase(''' || this.date_from::text ||  ''', ''' || this.date_to::text || ''', ' || _office_id::text || ') *-1 WHERE item_id=3000;';
            EXECUTE _sql;

            _sql := 'UPDATE pl_temp SET "' || this.period_name || '"=transactions.get_closing_stock(''' || this.date_from::text ||  ''', ' || _office_id::text || ') WHERE item_id=4000;';
            EXECUTE _sql;
        END IF;
    END LOOP;

    --Updating the column "amount" on each row by the sum of all periods.
    SELECT 'UPDATE pl_temp SET amount = ' || array_to_string(array_agg('COALESCE("' || period_name || '", 0)'), ' +') || ';'::text INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;

    --Updating amount and periodic balances on parent item by the sum of their respective child balances.
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') || 
    ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, '
        || array_to_string(array_agg('SUM("' || period_name || '") AS "' || period_name || '"'), ',') || '
         FROM pl_temp
        GROUP BY parent_item_id
    ) 
    AS tran
        WHERE tran.parent_item_id = pl_temp.item_id;'
    INTO _sql
    FROM explode_array(_periods);
    EXECUTE _sql;
    

    --Updating Gross Profit.
    --Gross Profit = Revenue - (Cost of Sales + Direct Costs)
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') 
    || ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 1000 THEN amount ELSE amount * -1 END) AS amount, '
        || array_to_string(array_agg('SUM(CASE item_id WHEN 1000 THEN "' || period_name || '" ELSE "' || period_name || '" *-1 END) AS "' || period_name || '"'), ',') ||
    '
         FROM pl_temp
         WHERE item_id IN
         (
             1000,2000,5000
         )
    ) 
    AS tran
    WHERE item_id = 6000;'
    INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;


    --Updating Operating Profit.
    --Operating Profit = Gross Profit - Operating Expenses
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') 
    || ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 6000 THEN amount ELSE amount * -1 END) AS amount, '
        || array_to_string(array_agg('SUM(CASE item_id WHEN 6000 THEN "' || period_name || '" ELSE "' || period_name || '" *-1 END) AS "' || period_name || '"'), ',') ||
    '
         FROM pl_temp
         WHERE item_id IN
         (
             6000, 7000
         )
    ) 
    AS tran
    WHERE item_id = 8000;'
    INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;

    --Updating Profit Before Income Taxes.
    --Profit Before Income Taxes = Operating Profit + Nonoperating Incomes + Financial Incomes - Financial Expenses
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') 
    || ' FROM 
    (
        SELECT
        SUM(CASE WHEN item_id IN(11000, 11100) THEN amount *-1 ELSE amount END) AS amount, '
        || array_to_string(array_agg('SUM(CASE WHEN item_id IN(11000, 11100) THEN "' || period_name || '"*-1  ELSE "' || period_name || '" END) AS "' || period_name || '"'), ',') ||
    '
         FROM pl_temp
         WHERE item_id IN
         (
             8000, 9000, 10000, 11000, 11100
         )
    ) 
    AS tran
    WHERE item_id = 12000;'
    INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;

    --Updating Income Tax Provison.
    --Income Tax Provison = Profit Before Income Taxes * Income Tax Rate - Paid Income Taxes
    SELECT * INTO this FROM pl_temp WHERE item_id = 12000;
    
    _sql := 'UPDATE pl_temp SET amount = finance.get_income_tax_provison_amount(' || _office_id::text || ',' || this.amount::text || ',(SELECT amount FROM pl_temp WHERE item_id = 13000)), ' 
    || array_to_string(array_agg('"' || period_name || '"=finance.get_income_tax_provison_amount(' || _office_id::text || ',' || 
    core.get_hstore_field(hstore(this.*), period_name) || ', (SELECT "' || period_name || '" FROM pl_temp WHERE item_id = 13000))'), ',')
            || ' WHERE item_id = 13001;'
    FROM explode_array(_periods);

    EXECUTE _sql;

    --Updating amount and periodic balances on parent item by the sum of their respective child balances, once again to add the Income Tax Provison to Income Tax Expenses.
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') 
    || ' FROM 
    (
        SELECT parent_item_id,
        SUM(amount) AS amount, '
        || array_to_string(array_agg('SUM("' || period_name || '") AS "' || period_name || '"'), ',') ||
    '
         FROM pl_temp
        GROUP BY parent_item_id
    ) 
    AS tran
        WHERE tran.parent_item_id = pl_temp.item_id;'
    INTO _sql
    FROM explode_array(_periods);
    EXECUTE _sql;


    --Updating Net Profit.
    --Net Profit = Profit Before Income Taxes - Income Tax Expenses
    SELECT 'UPDATE pl_temp SET amount = tran.amount, ' || array_to_string(array_agg('"' || period_name || '"=tran."' || period_name || '"'), ',') 
    || ' FROM 
    (
        SELECT
        SUM(CASE item_id WHEN 13000 THEN amount *-1 ELSE amount END) AS amount, '
        || array_to_string(array_agg('SUM(CASE item_id WHEN 13000 THEN "' || period_name || '"*-1  ELSE "' || period_name || '" END) AS "' || period_name || '"'), ',') ||
    '
         FROM pl_temp
         WHERE item_id IN
         (
             12000, 13000
         )
    ) 
    AS tran
    WHERE item_id = 14000;'
    INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;

    --Removing ledgers having zero balances
    DELETE FROM pl_temp
    WHERE COALESCE(amount, 0) = 0
    AND account_id IS NOT NULL;


    --Dividing by the factor.
    SELECT 'UPDATE pl_temp SET amount = amount /' || _factor::text || ',' || array_to_string(array_agg('"' || period_name || '"="' || period_name || '"/' || _factor::text), ',') || ';'
    INTO _sql
    FROM explode_array(_periods);
    EXECUTE _sql;


    --Converting 0's to NULLS.
    SELECT 'UPDATE pl_temp SET amount = CASE WHEN amount = 0 THEN NULL ELSE amount END,' || array_to_string(array_agg('"' || period_name || '"= CASE WHEN "' || period_name || '" = 0 THEN NULL ELSE "' || period_name || '" END'), ',') || ';'
    INTO _sql
    FROM explode_array(_periods);

    EXECUTE _sql;

    IF(_compact) THEN
        SELECT array_to_json(array_agg(row_to_json(report)))
        INTO _json
        FROM
        (
            SELECT item, amount, is_profit, is_summation
            FROM pl_temp
            ORDER BY item_id
        ) AS report;
    ELSE
        SELECT 
        'SELECT array_to_json(array_agg(row_to_json(report)))
        FROM
        (
            SELECT item, amount,'
            || array_to_string(array_agg('"' || period_name || '"'), ',') ||
            ', is_profit, is_summation FROM pl_temp
            ORDER BY item_id
        ) AS report;'
        INTO _sql
        FROM explode_array(_periods);

        EXECUTE _sql INTO _json ;
    END IF;    

    RETURN _json;
END
$$
LANGUAGE plpgsql;

-- SELECT * FROM finance.get_profit_and_loss_statement
-- (
--     '1-1-2010',
--     '1-1-2020',
--     1,
--     1,
--     1,
--     FALSE
-- );


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/finance.get_transaction_code.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_transaction_code(value_date date, office_id integer, user_id integer, login_id bigint);

CREATE FUNCTION finance.get_transaction_code(value_date date, office_id integer, user_id integer, login_id bigint)
RETURNS text
AS
$$
    DECLARE _office_id bigint:=$2;
    DECLARE _user_id integer:=$3;
    DECLARE _login_id bigint:=$4;
    DECLARE _ret_val text;  
BEGIN
    _ret_val:= finance.get_new_transaction_counter($1)::text || '-' || TO_CHAR($1, 'YYYY-MM-DD') || '-' || CAST(_office_id as text) || '-' || CAST(_user_id as text) || '-' || CAST(_login_id as text)   || '-' ||  TO_CHAR(now(), 'HH24-MI-SS');
    RETURN _ret_val;
END
$$
LANGUAGE plpgsql;



-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/02.functions-and-logic/logic/finance.get_trial_balance.sql --<--<--
DROP FUNCTION IF EXISTS finance.get_trial_balance
(
    _date_from                      date,
    _date_to                        date,
    _user_id                        integer,
    _office_id                      integer,
    _compact                        boolean,
    _factor                         numeric(30, 6),
    _change_side_when_negative      boolean,
    _include_zero_balance_accounts  boolean
);

CREATE FUNCTION finance.get_trial_balance
(
    _date_from                      date,
    _date_to                        date,
    _user_id                        integer,
    _office_id                      integer,
    _compact                        boolean,
    _factor                         numeric(30, 6),
    _change_side_when_negative      boolean DEFAULT(true),
    _include_zero_balance_accounts  boolean DEFAULT(true)
)
RETURNS TABLE
(
    id                      integer,
    account_id              integer,
    account_number          text,
    account                 text,
    previous_debit          numeric(30, 6),
    previous_credit         numeric(30, 6),
    debit                   numeric(30, 6),
    credit                  numeric(30, 6),
    closing_debit           numeric(30, 6),
    closing_credit          numeric(30, 6)
)
AS
$$
BEGIN
    IF(_date_from = 'infinity') THEN
        RAISE EXCEPTION 'Invalid date.'
        USING ERRCODE='P3008';
    END IF;

    IF NOT EXISTS
    (
        SELECT 0 FROM core.offices
        WHERE office_id IN 
        (
            SELECT * FROM core.get_office_ids(_office_id)
        )
        HAVING count(DISTINCT currency_code) = 1
   ) THEN
        RAISE EXCEPTION 'Cannot produce trial balance of office(s) having different base currencies.'
        USING ERRCODE='P8002';
   END IF;


    DROP TABLE IF EXISTS temp_trial_balance;
    CREATE TEMPORARY TABLE temp_trial_balance
    (
        id                      integer,
        account_id              integer,
        account_number          text,
        account                 text,
        previous_debit          numeric(30, 6),
        previous_credit         numeric(30, 6),
        debit                   numeric(30, 6),
        credit                  numeric(30, 6),
        closing_debit           numeric(30, 6),
        closing_credit          numeric(30, 6),
        root_account_id         integer,
        normally_debit          boolean
    ) ON COMMIT DROP;

    INSERT INTO temp_trial_balance(account_id, previous_debit, previous_credit)    
    SELECT 
        verified_transaction_mat_view.account_id, 
        SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
        SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
    FROM finance.verified_transaction_mat_view
    WHERE value_date < _date_from
    AND office_id IN (SELECT * FROM core.get_office_ids(_office_id))
    GROUP BY verified_transaction_mat_view.account_id;

    IF(_date_to = 'infinity') THEN
        INSERT INTO temp_trial_balance(account_id, debit, credit)    
        SELECT 
            verified_transaction_mat_view.account_id, 
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
        FROM finance.verified_transaction_mat_view
        WHERE value_date > _date_from
        AND office_id IN (SELECT * FROM core.get_office_ids(_office_id))
        GROUP BY verified_transaction_mat_view.account_id;
    ELSE
        INSERT INTO temp_trial_balance(account_id, debit, credit)    
        SELECT 
            verified_transaction_mat_view.account_id, 
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE 0 END),
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE 0 END)        
        FROM finance.verified_transaction_mat_view
        WHERE value_date >= _date_from AND value_date <= _date_to
        AND office_id IN (SELECT * FROM core.get_office_ids(_office_id))
        GROUP BY verified_transaction_mat_view.account_id;    
    END IF;

    UPDATE temp_trial_balance SET root_account_id = finance.get_root_account_id(temp_trial_balance.account_id);


    DROP TABLE IF EXISTS temp_trial_balance2;
    
    IF(_compact) THEN
        CREATE TEMPORARY TABLE temp_trial_balance2
        ON COMMIT DROP
        AS
        SELECT
            temp_trial_balance.root_account_id AS account_id,
            ''::text as account_number,
            ''::text as account,
            SUM(temp_trial_balance.previous_debit) AS previous_debit,
            SUM(temp_trial_balance.previous_credit) AS previous_credit,
            SUM(temp_trial_balance.debit) AS debit,
            SUM(temp_trial_balance.credit) as credit,
            SUM(temp_trial_balance.closing_debit) AS closing_debit,
            SUM(temp_trial_balance.closing_credit) AS closing_credit,
            temp_trial_balance.normally_debit
        FROM temp_trial_balance
        GROUP BY 
            temp_trial_balance.root_account_id,
            temp_trial_balance.normally_debit
        ORDER BY temp_trial_balance.normally_debit;
    ELSE
        CREATE TEMPORARY TABLE temp_trial_balance2
        ON COMMIT DROP
        AS
        SELECT
            temp_trial_balance.account_id,
            ''::text as account_number,
            ''::text as account,
            SUM(temp_trial_balance.previous_debit) AS previous_debit,
            SUM(temp_trial_balance.previous_credit) AS previous_credit,
            SUM(temp_trial_balance.debit) AS debit,
            SUM(temp_trial_balance.credit) as credit,
            SUM(temp_trial_balance.closing_debit) AS closing_debit,
            SUM(temp_trial_balance.closing_credit) AS closing_credit,
            temp_trial_balance.normally_debit
        FROM temp_trial_balance
        GROUP BY 
            temp_trial_balance.account_id,
            temp_trial_balance.normally_debit
        ORDER BY temp_trial_balance.normally_debit;
    END IF;
    
    UPDATE temp_trial_balance2 SET
        account_number = finance.accounts.account_number,
        account = finance.accounts.account_name,
        normally_debit = finance.account_masters.normally_debit
    FROM finance.accounts
    INNER JOIN finance.account_masters
    ON finance.accounts.account_master_id = finance.account_masters.account_master_id
    WHERE temp_trial_balance2.account_id = finance.accounts.account_id;

    UPDATE temp_trial_balance2 SET 
        closing_debit = COALESCE(temp_trial_balance2.previous_debit, 0) + COALESCE(temp_trial_balance2.debit, 0),
        closing_credit = COALESCE(temp_trial_balance2.previous_credit, 0) + COALESCE(temp_trial_balance2.credit, 0);
        


     UPDATE temp_trial_balance2 SET previous_debit = COALESCE(temp_trial_balance2.previous_debit, 0) - COALESCE(temp_trial_balance2.previous_credit, 0), previous_credit = NULL WHERE normally_debit;
     UPDATE temp_trial_balance2 SET previous_credit = COALESCE(temp_trial_balance2.previous_credit, 0) - COALESCE(temp_trial_balance2.previous_debit, 0), previous_debit = NULL WHERE NOT normally_debit;
 
     UPDATE temp_trial_balance2 SET debit = COALESCE(temp_trial_balance2.debit, 0) - COALESCE(temp_trial_balance2.credit, 0), credit = NULL WHERE normally_debit;
     UPDATE temp_trial_balance2 SET credit = COALESCE(temp_trial_balance2.credit, 0) - COALESCE(temp_trial_balance2.debit, 0), debit = NULL WHERE NOT normally_debit;
 
     UPDATE temp_trial_balance2 SET closing_debit = COALESCE(temp_trial_balance2.closing_debit, 0) - COALESCE(temp_trial_balance2.closing_credit, 0), closing_credit = NULL WHERE normally_debit;
     UPDATE temp_trial_balance2 SET closing_credit = COALESCE(temp_trial_balance2.closing_credit, 0) - COALESCE(temp_trial_balance2.closing_debit, 0), closing_debit = NULL WHERE NOT normally_debit;


    IF(NOT _include_zero_balance_accounts) THEN
        DELETE FROM temp_trial_balance2 WHERE COALESCE(temp_trial_balance2.closing_debit, 0) + COALESCE(temp_trial_balance2.closing_credit, 0) = 0;
    END IF;
    
    IF(_factor > 0) THEN
        UPDATE temp_trial_balance2 SET previous_debit   = temp_trial_balance2.previous_debit/_factor;
        UPDATE temp_trial_balance2 SET previous_credit  = temp_trial_balance2.previous_credit/_factor;
        UPDATE temp_trial_balance2 SET debit            = temp_trial_balance2.debit/_factor;
        UPDATE temp_trial_balance2 SET credit           = temp_trial_balance2.credit/_factor;
        UPDATE temp_trial_balance2 SET closing_debit    = temp_trial_balance2.closing_debit/_factor;
        UPDATE temp_trial_balance2 SET closing_credit   = temp_trial_balance2.closing_credit/_factor;
    END IF;

    --Remove Zeros
    UPDATE temp_trial_balance2 SET previous_debit = NULL WHERE temp_trial_balance2.previous_debit = 0;
    UPDATE temp_trial_balance2 SET previous_credit = NULL WHERE temp_trial_balance2.previous_credit = 0;
    UPDATE temp_trial_balance2 SET debit = NULL WHERE temp_trial_balance2.debit = 0;
    UPDATE temp_trial_balance2 SET credit = NULL WHERE temp_trial_balance2.credit = 0;
    UPDATE temp_trial_balance2 SET closing_debit = NULL WHERE temp_trial_balance2.closing_debit = 0;
    UPDATE temp_trial_balance2 SET closing_debit = NULL WHERE temp_trial_balance2.closing_credit = 0;

    IF(_change_side_when_negative) THEN
        UPDATE temp_trial_balance2 SET previous_debit = temp_trial_balance2.previous_credit * -1, previous_credit = NULL WHERE temp_trial_balance2.previous_credit < 0;
        UPDATE temp_trial_balance2 SET previous_credit = temp_trial_balance2.previous_debit * -1, previous_debit = NULL WHERE temp_trial_balance2.previous_debit < 0;

        UPDATE temp_trial_balance2 SET debit = temp_trial_balance2.credit * -1, credit = NULL WHERE temp_trial_balance2.credit < 0;
        UPDATE temp_trial_balance2 SET credit = temp_trial_balance2.debit * -1, debit = NULL WHERE temp_trial_balance2.debit < 0;

        UPDATE temp_trial_balance2 SET closing_debit = temp_trial_balance2.closing_credit * -1, closing_credit = NULL WHERE temp_trial_balance2.closing_credit < 0;
        UPDATE temp_trial_balance2 SET closing_credit = temp_trial_balance2.closing_debit * -1, closing_debit = NULL WHERE temp_trial_balance2.closing_debit < 0;
    END IF;
    
    RETURN QUERY
    SELECT
        row_number() OVER(ORDER BY temp_trial_balance2.normally_debit DESC, temp_trial_balance2.account_id)::integer AS id,
        temp_trial_balance2.account_id,
        temp_trial_balance2.account_number,
        temp_trial_balance2.account,
        temp_trial_balance2.previous_debit,
        temp_trial_balance2.previous_credit,
        temp_trial_balance2.debit,
        temp_trial_balance2.credit,
        temp_trial_balance2.closing_debit,
        temp_trial_balance2.closing_credit
    FROM temp_trial_balance2;
END
$$
LANGUAGE plpgsql;

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/04.default-values/01.default-values.sql --<--<--
UPDATE finance.accounts
SET account_master_id = finance.get_account_master_id_by_account_master_code('ACP')
WHERE account_name = 'Interest Payable';


UPDATE finance.accounts
SET account_master_id = finance.get_account_master_id_by_account_master_code('FII')
WHERE account_name = 'Finance Charge Income';


DO
$$
BEGIN
    IF NOT EXISTS(SELECT 0 FROM finance.account_masters WHERE account_master_code='LOP') THEN
        INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, normally_debit, parent_account_master_id)
        SELECT 15009, 'LOP', 'Loan Payables', false, 1;

		UPDATE finance.accounts
		SET account_master_id = 15009
		WHERE account_name IN('Loan Payable', 'Bank Loans Payable');
    END IF;

    IF NOT EXISTS(SELECT 0 FROM finance.account_masters WHERE account_master_code='LAD') THEN
        INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, normally_debit, parent_account_master_id)
        SELECT 10104, 'LAD', 'Loan & Advances', true, 1;

		UPDATE finance.accounts
		SET account_master_id = 10104
		WHERE account_name = 'Loan & Advances';
    END IF;
END
$$
LANGUAGE plpgsql;


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/05.scrud-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/05.selector-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/05.views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/05.views/finance.verified_transaction_journal_view.sql --<--<--
DROP VIEW IF EXISTS finance.verified_transaction_journal_view;

CREATE VIEW finance.verified_transaction_journal_view
AS
SELECT
    finance.verified_transaction_view.transaction_master_id,
    finance.verified_transaction_view.book,
    finance.verified_transaction_view.transaction_detail_id,
    finance.verified_transaction_view.account_id,
    finance.verified_transaction_view.account_name,
    CASE WHEN finance.verified_transaction_view.tran_type = 'Dr' THEN finance.verified_transaction_view.amount_in_local_currency ELSE 0 END AS dr,
    CASE WHEN finance.verified_transaction_view.tran_type = 'Cr' THEN finance.verified_transaction_view.amount_in_local_currency ELSE 0 END AS cr
FROM finance.verified_transaction_view;

-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/06.report-views/empty.sql --<--<--


-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/PostgreSQL/2.1.update/src/99.ownership.sql --<--<--
DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.schemaname || '.' || this.tablename ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'ALTER TABLE '|| this.mat_view ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') OWNER TO frapid_db_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'frapid_db_user'
    LOOP
        EXECUTE 'ALTER VIEW '|| this.schemaname || '.' || this.viewname ||' OWNER TO frapid_db_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'ALTER SCHEMA ' || nspname || ' OWNER TO frapid_db_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;



DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'frapid_db_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT      'ALTER TYPE ' || n.nspname || '.' || t.typname || ' OWNER TO frapid_db_user;' AS sql
    FROM        pg_type t 
    LEFT JOIN   pg_catalog.pg_namespace n ON n.oid = t.typnamespace 
    WHERE       (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) 
    AND         NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
    AND         typtype NOT IN ('b')
    AND         n.nspname NOT IN ('pg_catalog', 'information_schema')
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_tables 
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND tableowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.schemaname || '.' || this.tablename ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT oid::regclass::text as mat_view
    FROM   pg_class
    WHERE  relkind = 'm'
    LOOP
        EXECUTE 'GRANT SELECT ON TABLE '|| this.mat_view  ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;

DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT EXECUTE ON '
        || CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END
        || quote_ident(n.nspname) || '.' || quote_ident(p.proname) || '(' 
        || pg_catalog.pg_get_function_identity_arguments(p.oid) || ') TO report_user;' AS sql
    FROM   pg_catalog.pg_proc p
    JOIN   pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE  NOT n.nspname = ANY(ARRAY['pg_catalog', 'information_schema'])
    LOOP        
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT * FROM pg_views
    WHERE NOT schemaname = ANY(ARRAY['pg_catalog', 'information_schema'])
    AND viewowner <> 'report_user'
    LOOP
        EXECUTE 'GRANT SELECT ON '|| this.schemaname || '.' || this.viewname ||' TO report_user;';
    END LOOP;
END
$$
LANGUAGE plpgsql;


DO
$$
    DECLARE this record;
BEGIN
    IF(CURRENT_USER = 'report_user') THEN
        RETURN;
    END IF;

    FOR this IN 
    SELECT 'GRANT USAGE ON SCHEMA ' || nspname || ' TO report_user;' AS sql FROM pg_namespace
    WHERE nspname NOT LIKE 'pg_%'
    AND nspname <> 'information_schema'
    LOOP
        EXECUTE this.sql;
    END LOOP;
END
$$
LANGUAGE plpgsql;


