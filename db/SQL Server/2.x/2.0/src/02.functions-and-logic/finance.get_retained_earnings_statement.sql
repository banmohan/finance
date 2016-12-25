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
