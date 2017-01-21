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
