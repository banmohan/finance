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
