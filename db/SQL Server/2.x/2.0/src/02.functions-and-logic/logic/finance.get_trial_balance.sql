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
