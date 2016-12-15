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
    @compact                        bit
)
AS
BEGIN    
    --DECLARE @sql                    national character varying(1000);
    --DECLARE @periods                finance.period;
    --DECLARE @json                   json;
    --DECLARE this                    RECORD;
    --DECLARE @balance                numeric(30, 6);
    --DECLARE @is_periodic            bit = finance.is_periodic_inventory(@office_id);

    --CREATE TABLE #pl_temp
    --(
    --    item_id                     integer PRIMARY KEY,
    --    item                        national character varying(1000),
    --    account_id                  integer,
    --    parent_item_id              integer,
    --    is_profit                   bit DEFAULT(0),
    --    is_summation                bit DEFAULT(0),
    --    is_debit                    bit DEFAULT(0),
    --    amount                      numeric(30, 6) DEFAULT(0)
    --);

    --IF(COALESCE(@factor, 0) = 0)
    --BEGIN
    --    @factor = 1;
    --END;

    --INSERT INTO @periods
    --SELECT * FROM finance.get_periods(@date_from, @date_to);

    --IF NOT EXISTS(SELECT * FROM @periods)
    --BEGIN
    --    RAISERROR('Invalid period specified.', 10, 1);
    --END;

    --SELECT string_agg(dynamic, '') FROM
    --(
    --        SELECT 'ALTER TABLE #pl_temp ADD COLUMN "' + period_name + '" numeric(30, 6) DEFAULT(0);' as dynamic
    --        FROM @periods
         
    --) periods
    --INTO @sql;
    
    --EXECUTE @sql;

    ----PL structure setup start
    --INSERT INTO #pl_temp(item_id, item, is_summation, parent_item_id)
    --SELECT 1000,   'Revenue',                      1,   NULL     UNION ALL
    --SELECT 2000,   'Cost of Sales',                1,   NULL     UNION ALL
    --SELECT 2001,   'Opening Stock',                0,  1000     UNION ALL
    --SELECT 3000,   'Purchases',                    0,  1000     UNION ALL
    --SELECT 4000,   'Closing Stock',                0,  1000     UNION ALL
    --SELECT 5000,   'Direct Costs',                 1,   NULL     UNION ALL
    --SELECT 6000,   'Gross Profit',                 0,  NULL     UNION ALL
    --SELECT 7000,   'Operating Expenses',           1,   NULL     UNION ALL
    --SELECT 8000,   'Operating Profit',             0,  NULL     UNION ALL
    --SELECT 9000,   'Nonoperating Incomes',         1,   NULL     UNION ALL
    --SELECT 10000,  'Financial Incomes',            1,   NULL     UNION ALL
    --SELECT 11000,  'Financial Expenses',           1,   NULL     UNION ALL
    --SELECT 11100,  'Interest Expenses',            1,   11000    UNION ALL
    --SELECT 12000,  'Profit Before Income Taxes',   0,  NULL     UNION ALL
    --SELECT 13000,  'Income Taxes',                 1,   NULL     UNION ALL
    --SELECT 13001,  'Income Tax Provison',          0,  13000    UNION ALL
    --SELECT 14000,  'Net Profit',                   1,   NULL;

    --UPDATE #pl_temp SET is_debit = 1 WHERE item_id IN(2001, 3000, 4000);
    --UPDATE #pl_temp SET is_profit = 1 WHERE item_id IN(6000,8000, 12000, 14000);
    
    --INSERT INTO #pl_temp(item_id, account_id, item, parent_item_id, is_debit)
    --SELECT id, account_id, account_name, 1000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20100, 1000) UNION ALL--Sales Accounts
    --SELECT id, account_id, account_name, 2000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20400, 2001) UNION ALL--COGS Accounts
    --SELECT id, account_id, account_name, 5000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20500, 5000) UNION ALL--Direct Cost
    --SELECT id, account_id, account_name, 7000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20600, 7000) UNION ALL--Operating Expenses
    --SELECT id, account_id, account_name, 9000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20200, 9000) UNION ALL--Nonoperating Incomes
    --SELECT id, account_id, account_name, 10000 as parent_item_id, 0 as is_debit FROM core.get_account_view_by_account_master_id(20300, 10000) UNION ALL--Financial Incomes
    --SELECT id, account_id, account_name, 11000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20700, 11000) UNION ALL--Financial Expenses
    --SELECT id, account_id, account_name, 11100 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20701, 11100) UNION ALL--Interest Expenses
    --SELECT id, account_id, account_name, 13000 as parent_item_id, 1 as is_debit FROM core.get_account_view_by_account_master_id(20800, 13001);--Income Tax Expenses

    --IF(NOT @is_periodic)
    --BEGIN
    --    DELETE FROM #pl_temp WHERE item_id IN(2001, 3000, 4000);
    --END;
    ----PL structure setup END;


    --FOR this IN 
    --SELECT * FROM @periods 
    --ORDER BY date_from ASC
    --LOOP
    --    --Updating credit balances of individual GL accounts.
    --    @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=tran.total_amount
    --    FROM
    --    (
    --        SELECT finance.verified_transaction_mat_view.account_id,
    --        SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
    --        SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
    --    FROM finance.verified_transaction_mat_view
    --    WHERE value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
    --    ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --    GROUP BY finance.verified_transaction_mat_view.account_id
    --    ) AS tran
    --    WHERE tran.account_id = #pl_temp.account_id';
    --    EXECUTE @sql;

    --    --Reversing to debit balance for expense headings.
    --    @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"="' + this.period_name + '"*-1 WHERE is_debit;';
    --    EXECUTE @sql;

    --    --Getting purchase and stock balances if this is a periodic inventory system.
    --    --In perpetual accounting system, one would not need to include these headings 
    --    --because the COGS A/C would be automatically updated on each transaction.
    --    IF(@is_periodic)
    --    BEGIN
    --        @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_closing_stock(''' + CAST(DATEADD(day,-1,this.date_from) AS varchar(24)) +  ''', ' + CAST(@office_id AS varchar(100)) + ') WHERE item_id=2001;';
    --        EXECUTE @sql;

    --        @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_purchase(''' + CAST(this.date_from AS varchar(24)) +  ''', ''' + CAST(this.date_to AS varchar(24)) + ''', ' + CAST(@office_id AS varchar(100)) + ') *-1 WHERE item_id=3000;';
    --        EXECUTE @sql;

    --        @sql = 'UPDATE #pl_temp SET "' + this.period_name + '"=finance.get_closing_stock(''' + CAST(this.date_from AS varchar(24)) +  ''', ' + CAST(@office_id AS varchar(100)) + ') WHERE item_id=4000;';
    --        EXECUTE @sql;
    --    END;
    --END LOOP;

    ----Updating the column "amount" on each row by the sum of all periods.
    --SELECT 'UPDATE #pl_temp SET amount = ' + array_to_string(array_agg('COALESCE("' + period_name + '", 0)'), ' +') + ';' INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    ----Updating amount and periodic balances on parent item by the sum of their respective child balances.
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') + 
    --' FROM 
    --(
    --    SELECT parent_item_id,
    --    SUM(amount) AS amount, '
    --    + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') + '
    --     FROM #pl_temp
    --    GROUP BY parent_item_id
    --) 
    --AS tran
    --    WHERE tran.parent_item_id = #pl_temp.item_id;'
    --INTO @sql
    --FROM @periods;
    --EXECUTE @sql;

    ----Updating Gross Profit.
    ----Gross Profit = Revenue - (Cost of Sales + Direct Costs)
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT
    --    SUM(CASE item_id WHEN 1000 THEN amount ELSE amount * -1 END) AS amount, '
    --    + array_to_string(array_agg('SUM(CASE item_id WHEN 1000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    --'
    --     FROM #pl_temp
    --     WHERE item_id IN
    --     (
    --         1000,2000,5000
    --     )
    --) 
    --AS tran
    --WHERE item_id = 6000;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;


    ----Updating Operating Profit.
    ----Operating Profit = Gross Profit - Operating Expenses
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT
    --    SUM(CASE item_id WHEN 6000 THEN amount ELSE amount * -1 END) AS amount, '
    --    + array_to_string(array_agg('SUM(CASE item_id WHEN 6000 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    --'
    --     FROM #pl_temp
    --     WHERE item_id IN
    --     (
    --         6000, 7000
    --     )
    --) 
    --AS tran
    --WHERE item_id = 8000;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    ----Updating Profit Before Income Taxes.
    ----Profit Before Income Taxes = Operating Profit + Nonoperating Incomes + Financial Incomes - Financial Expenses
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT
    --    SUM(CASE WHEN item_id IN(11000, 11100) THEN amount *-1 ELSE amount END) AS amount, '
    --    + array_to_string(array_agg('SUM(CASE WHEN item_id IN(11000, 11100) THEN "' + period_name + '"*-1  ELSE "' + period_name + '" END) AS "' + period_name + '"'), ',') +
    --'
    --     FROM #pl_temp
    --     WHERE item_id IN
    --     (
    --         8000, 9000, 10000, 11000, 11100
    --     )
    --) 
    --AS tran
    --WHERE item_id = 12000;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    ----Updating Income Tax Provison.
    ----Income Tax Provison = Profit Before Income Taxes * Income Tax Rate - Paid Income Taxes
    --SELECT * INTO this FROM #pl_temp WHERE item_id = 12000;
    
    --@sql = 'UPDATE #pl_temp SET amount = core.get_income_tax_provison_amount(' + CAST(@office_id AS varchar(100)) + ',' + CAST(this.amount AS varchar(100)) + ',(SELECT amount FROM #pl_temp WHERE item_id = 13000)), ' 
    --+ array_to_string(array_agg('"' + period_name + '"=core.get_income_tax_provison_amount(' + CAST(@office_id AS varchar(100)) + ',' + core.get_field(hstore(this.*), period_name) + ', (SELECT "' + period_name + '" FROM #pl_temp WHERE item_id = 13000))'), ',')
    --        + ' WHERE item_id = 13001;'
    --FROM @periods;

    --EXECUTE @sql;

    ----Updating amount and periodic balances on parent item by the sum of their respective child balances, once again to add the Income Tax Provison to Income Tax Expenses.
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT parent_item_id,
    --    SUM(amount) AS amount, '
    --    + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') +
    --'
    --     FROM #pl_temp
    --    GROUP BY parent_item_id
    --) 
    --AS tran
    --    WHERE tran.parent_item_id = #pl_temp.item_id;'
    --INTO @sql
    --FROM @periods;
    --EXECUTE @sql;


    ----Updating Net Profit.
    ----Net Profit = Profit Before Income Taxes - Income Tax Expenses
    --SELECT 'UPDATE #pl_temp SET amount = tran.amount, ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT
    --    SUM(CASE item_id WHEN 13000 THEN amount *-1 ELSE amount END) AS amount, '
    --    + array_to_string(array_agg('SUM(CASE item_id WHEN 13000 THEN "' + period_name + '"*-1  ELSE "' + period_name + '" END) AS "' + period_name + '"'), ',') +
    --'
    --     FROM #pl_temp
    --     WHERE item_id IN
    --     (
    --         12000, 13000
    --     )
    --) 
    --AS tran
    --WHERE item_id = 14000;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    ----Removing ledgers having zero balances
    --DELETE FROM #pl_temp
    --WHERE COALESCE(amount, 0) = 0
    --AND account_id IS NOT NULL;


    ----Dividing by the factor.
    --SELECT 'UPDATE #pl_temp SET amount = amount /' + CAST(@factor varchar(100)) + ',' + array_to_string(array_agg('"' + period_name + '"="' + period_name + '"/' + CAST(@factor varchar(100))), ',') + ';'
    --INTO @sql
    --FROM @periods;
    --EXECUTE @sql;


    ----Converting 0's to NULLS.
    --SELECT 'UPDATE #pl_temp SET amount = CASE WHEN amount = 0 THEN NULL ELSE amount END,' + array_to_string(array_agg('"' + period_name + '"= CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'), ',') + ';'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    --IF(@compact)
    --BEGIN
    --    SELECT array_to_json(array_agg(row_to_json(report)))
    --    INTO @json
    --    FROM
    --    (
    --        SELECT item, amount, is_profit, is_summation
    --        FROM #pl_temp
    --        ORDER BY item_id
    --    ) AS report;
    --END
    --ELSE
    --BEGIN
    --    SELECT 
    --    'SELECT array_to_json(array_agg(row_to_json(report)))
    --    FROM
    --    (
    --        SELECT item, amount,'
    --        + array_to_string(array_agg('"' + period_name + '"'), ',') +
    --        ', is_profit, is_summation FROM #pl_temp
    --        ORDER BY item_id
    --    ) AS report;'
    --    INTO @sql
    --    FROM @periods;

    --    EXECUTE @sql INTO @json ;
    --END;    

    --SELECT @json;

    --TODO
    RETURN;
END

GO