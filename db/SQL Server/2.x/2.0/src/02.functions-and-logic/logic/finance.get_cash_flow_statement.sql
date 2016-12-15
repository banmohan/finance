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
    --DECLARE @sql                    national character varying(1000);
    --DECLARE @periods                finance.period;
    --DECLARE @json                   json;
    --DECLARE this                    RECORD;
    --DECLARE @balance                numeric(30, 6);
    --DECLARE @is_periodic            bit = finance.is_periodic_inventory(@office_id);

    ----We cannot divide by zero.
    --IF(COALESCE(@factor, 0) = 0)
    --BEGIN
    --    @factor = 1;
    --END;

    --CREATE TABLE #cf_temp
    --(
    --    item_id                     integer PRIMARY KEY,
    --    item                        national character varying(1000),
    --    account_master_id           integer,
    --    parent_item_id              integer REFERENCES #cf_temp(item_id),
    --    is_summation                bit DEFAULT(0),
    --    is_debit                    bit DEFAULT(0),
    --    is_sales                    bit DEFAULT(0),
    --    is_purchase                 bit DEFAULT(0)
    --) ;


    --INSERT INTO @periods
    --SELECT * FROM finance.get_periods(@date_from, @date_to);

    --IF NOT EXISTS(SELECT * FROM @periods)
    --BEGIN
    --    RAISERROR('Invalid period specified.', 10, 1);
    --END;

    --/**************************************************************************************************************************************************************************************
    --    CREATING PERIODS
    --**************************************************************************************************************************************************************************************/
    --SELECT string_agg(dynamic, '') FROM
    --(
    --    SELECT 'ALTER TABLE #cf_temp ADD COLUMN "' + period_name + '" numeric(30, 6) DEFAULT(0);' as dynamic
    --    FROM @periods         
    --) periods
    --INTO @sql;
    
    --EXECUTE @sql;

    --/**************************************************************************************************************************************************************************************
    --    CASHFLOW TABLE STRUCTURE START
    --**************************************************************************************************************************************************************************************/
    --INSERT INTO #cf_temp(item_id, item, is_summation, is_debit)
    --SELECT  10000,  'Cash and cash equivalents, beginning of period',   0,  1    UNION ALL    
    --SELECT  20000,  'Cash flows from operating activities',             1,   0   UNION ALL    
    --SELECT  30000,  'Cash flows from investing activities',             1,   0   UNION ALL
    --SELECT  40000,  'Cash flows from financing acticities',             1,   0   UNION ALL    
    --SELECT  50000,  'Net increase in cash and cash equivalents',        0,  0   UNION ALL    
    --SELECT  60000,  'Cash and cash equivalents, end of period',         0,  1;    

    --INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, is_sales, is_purchase)
    --SELECT  cash_flow_heading_id,   cash_flow_heading_name, 20000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'O' UNION ALL
    --SELECT  cash_flow_heading_id,   cash_flow_heading_name, 30000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'I' UNION ALL 
    --SELECT  cash_flow_heading_id,   cash_flow_heading_name, 40000,  is_debit,   is_sales,   is_purchase FROM core.cash_flow_headings WHERE cash_flow_heading_type = 'F';

    --INSERT INTO #cf_temp(item_id, item, parent_item_id, is_debit, account_master_id)
    --SELECT core.account_masters.account_master_id + 50000, core.account_masters.account_master_name,  core.cash_flow_setup.cash_flow_heading_id, core.cash_flow_headings.is_debit, core.account_masters.account_master_id
    --FROM core.cash_flow_setup
    --INNER JOIN core.account_masters
    --ON core.cash_flow_setup.account_master_id = core.account_masters.account_master_id
    --INNER JOIN core.cash_flow_headings
    --ON core.cash_flow_setup.cash_flow_heading_id = core.cash_flow_headings.cash_flow_heading_id;

    --/**************************************************************************************************************************************************************************************
    --    CASHFLOW TABLE STRUCTURE END
    --**************************************************************************************************************************************************************************************/


    --/**************************************************************************************************************************************************************************************
    --    ITERATING THROUGH PERIODS TO UPDATE TRANSACTION BALANCES
    --**************************************************************************************************************************************************************************************/
    --FOR this IN 
    --SELECT * 
    --FROM @periods 
    --ORDER BY date_from ASC
    --LOOP
    --    --
    --    --
    --    --Opening cash balance.
    --    --
    --    --
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
    --        (
    --            SELECT
    --            SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
    --            SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
    --        FROM finance.verified_cash_transaction_mat_view
    --        WHERE account_master_id IN(10101, 10102) 
    --        AND value_date <''' + CAST(this.date_from AS varchar(24)) +
    --        ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --        )
    --    WHERE #cf_temp.item_id = 10000;';

    --    EXECUTE @sql;

    --    --
    --    --
    --    --Updating debit balances of mapped account master heads.
    --    --
    --    --
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=tran.total_amount
    --    FROM
    --    (
    --        SELECT finance.verified_cash_transaction_mat_view.account_master_id,
    --        SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
    --        SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
    --    FROM finance.verified_cash_transaction_mat_view
    --    WHERE finance.verified_cash_transaction_mat_view.book NOT IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'', ''Purchase.Direct'', ''Purchase.Receipt'')
    --    AND account_master_id NOT IN(10101, 10102) 
    --    AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
    --    ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --    GROUP BY finance.verified_cash_transaction_mat_view.account_master_id
    --    ) AS tran
    --    WHERE tran.account_master_id = #cf_temp.account_master_id';
    --    EXECUTE @sql;

    --    --
    --    --
    --    --Updating cash paid to suppliers.
    --    --
    --    --
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
        
    --    (
    --        SELECT
    --        SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) - 
    --        SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) 
    --    FROM finance.verified_cash_transaction_mat_view
    --    WHERE finance.verified_cash_transaction_mat_view.book IN (''Purchase.Direct'', ''Purchase.Receipt'', ''Purchase.Payment'')
    --    AND account_master_id NOT IN(10101, 10102) 
    --    AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
    --    ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --    )
    --    WHERE #cf_temp.is_purchase;';
    --    EXECUTE @sql;

    --    --
    --    --
    --    --Updating cash received from customers.
    --    --
    --    --
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"=
        
    --    (
    --        SELECT
    --        SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
    --        SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) 
    --    FROM finance.verified_cash_transaction_mat_view
    --    WHERE finance.verified_cash_transaction_mat_view.book IN (''Sales.Direct'', ''Sales.Receipt'', ''Sales.Delivery'')
    --    AND account_master_id IN(10101, 10102) 
    --    AND value_date >=''' + CAST(this.date_from AS varchar(24)) + ''' AND value_date <=''' + CAST(this.date_to AS varchar(24)) +
    --    ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --    )
    --    WHERE #cf_temp.is_sales;';
    --    PRINT @SQL;
    --    EXECUTE @sql;

    --    --Closing cash balance.
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"
    --    =
    --    (
    --        SELECT
    --        SUM(CASE tran_type WHEN ''Cr'' THEN amount_in_local_currency ELSE 0 END) - 
    --        SUM(CASE tran_type WHEN ''Dr'' THEN amount_in_local_currency ELSE 0 END) AS total_amount
    --    FROM finance.verified_cash_transaction_mat_view
    --    WHERE account_master_id IN(10101, 10102) 
    --    AND value_date <''' + CAST(this.date_to AS varchar(24)) +
    --    ''' AND office_id IN (SELECT * FROM core.get_office_ids(' + CAST(@office_id AS varchar(100)) + '))
    --    ) 
    --    WHERE #cf_temp.item_id = 60000;';

    --    EXECUTE @sql;

    --    --Reversing to debit balance for associated headings.
    --    @sql = 'UPDATE #cf_temp SET "' + this.period_name + '"="' + this.period_name + '"*-1 WHERE is_debit= 1;';
    --    EXECUTE @sql;
    --END LOOP;



    ----Updating periodic balances on parent item by the sum of their respective child balances.
    --SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"' + '=#cf_temp."' + period_name + '" + tran."' + period_name + '"'), ',') + 
    --' FROM 
    --(
    --    SELECT parent_item_id, '
    --    + array_to_string(array_agg('SUM("' + period_name + '") AS "' + period_name + '"'), ',') + '
    --     FROM #cf_temp
    --    GROUP BY parent_item_id
    --) 
    --AS tran
    --    WHERE tran.parent_item_id = #cf_temp.item_id
    --    AND #cf_temp.item_id NOT IN (10000, 60000);'
    --INTO @sql
    --FROM @periods;

    --PRINT @SQL;
    --EXECUTE @sql;


    --SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"=tran."' + period_name + '"'), ',') 
    --+ ' FROM 
    --(
    --    SELECT
    --        #cf_temp.parent_item_id,'
    --    + array_to_string(array_agg('SUM(CASE is_debit WHEN 1 THEN "' + period_name + '" ELSE "' + period_name + '" *-1 END) AS "' + period_name + '"'), ',') +
    --'
    --     FROM #cf_temp
    --     GROUP BY #cf_temp.parent_item_id
    --) 
    --AS tran
    --WHERE #cf_temp.item_id = tran.parent_item_id
    --AND #cf_temp.parent_item_id IS NULL;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;


    ----Dividing by the factor.
    --SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"="' + period_name + '"/' + CAST(@factor AS varchar(100))), ',') + ';'
    --INTO @sql
    --FROM @periods;
    --EXECUTE @sql;


    ----Converting 0's to NULLS.
    --SELECT 'UPDATE #cf_temp SET ' + array_to_string(array_agg('"' + period_name + '"= CASE WHEN "' + period_name + '" = 0 THEN NULL ELSE "' + period_name + '" END'), ',') + ';'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql;

    --SELECT 
    --'SELECT array_to_json(array_agg(row_to_json(report)))
    --FROM
    --(
    --    SELECT item, '
    --    + array_to_string(array_agg('"' + period_name + '"'), ',') +
    --    ', is_summation FROM #cf_temp
    --    WHERE account_master_id IS NULL
    --    ORDER BY item_id
    --) AS report;'
    --INTO @sql
    --FROM @periods;

    --EXECUTE @sql INTO @json ;
    --TODO
    --SELECT @json;
    RETURN;
END

GO