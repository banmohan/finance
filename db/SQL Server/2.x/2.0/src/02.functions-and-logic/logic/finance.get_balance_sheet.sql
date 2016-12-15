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
    previous_period                 numeric(30, 6),
    current_period                  numeric(30, 6),
    account_id                      integer,
    account_number national character varying(24),
    is_retained_earning             bit
)
AS
BEGIN
 --   DECLARE @date_from              date = finance.get_fiscal_year_start_date(@office_id);

 --   IF(COALESCE(@factor, 0) = 0)
 --   BEGIN
 --       SET @factor = 1;
 --   END;

 --   DECLARE @balance_sheet TABLE
 --   (
 --       item_id                     integer PRIMARY KEY,
 --       item                        national character varying(1000),
 --       account_number              national character varying(24),
 --       account_id                  integer,
 --       child_accounts              national character varying(MAX),
 --       parent_item_id              integer,
 --       is_debit                    bit DEFAULT(0),
 --       previous_period             numeric(30, 6) DEFAULT(0),
 --       current_period              numeric(30, 6) DEFAULT(0),
 --       sort                        int,
 --       skip                        bit DEFAULT(0),
 --       is_retained_earning         bit DEFAULT(0)
 --   );
    
 --   --BS structure setup start
 --   INSERT INTO @balance_sheet(item_id, item, parent_item_id)
 --   SELECT  1,       'Assets',                              NULL            UNION ALL
 --   SELECT  10100,   'Current Assets',                      1               UNION ALL
 --   SELECT  10101,   'Cash A/C',                            1               UNION ALL
 --   SELECT  10102,   'Bank A/C',                            1               UNION ALL
 --   SELECT  10110,   'Accounts Receivable',                 10100           UNION ALL
 --   SELECT  10200,   'Fixed Assets',                        1               UNION ALL
 --   SELECT  10201,   'Property, Plants, and Equipments',    10201           UNION ALL
 --   SELECT  10300,   'Other Assets',                        1               UNION ALL
 --   SELECT  14900,   'Liabilities & Shareholders'' Equity', NULL            UNION ALL
 --   SELECT  15000,   'Current Liabilities',                 14900           UNION ALL
 --   SELECT  15010,   'Accounts Payable',                    15000           UNION ALL
 --   SELECT  15011,   'Salary Payable',                      15000           UNION ALL
 --   SELECT  15100,   'Long-Term Liabilities',               14900           UNION ALL
 --   SELECT  15200,   'Shareholders'' Equity',               14900           UNION ALL
 --   SELECT  15300,   'Retained Earnings',                   15200;

 --   UPDATE @balance_sheet SET is_debit = 1 WHERE @balance_sheet.item_id <= 10300;
 --   UPDATE @balance_sheet SET is_retained_earning = 1 WHERE @balance_sheet.item_id = 15300;
    
 --   INSERT INTO @balance_sheet(item_id, account_id, account_number, parent_item_id, item, is_debit, child_accounts)
 --   SELECT 
 --       row_number() OVER(ORDER BY finance.accounts.account_master_id) + (finance.accounts.account_master_id * 100) AS id,
 --       finance.accounts.account_id,
 --       finance.accounts.account_number,
 --       finance.accounts.account_master_id,
 --       finance.accounts.account_name,
 --       finance.account_masters.normally_debit,
 --       array_agg(agg)
 --   FROM finance.accounts
 --   INNER JOIN finance.account_masters
 --   ON finance.accounts.account_master_id = finance.account_masters.account_master_id,
 --   finance.get_account_ids(finance.accounts.account_id) as agg
 --   WHERE parent_account_id IN
 --   (
 --       SELECT finance.accounts.account_id
 --       FROM finance.accounts
 --       WHERE finance.accounts.sys_type = 1
 --       AND finance.accounts.account_master_id BETWEEN 10100 AND 15200
 --   )
 --   AND finance.accounts.account_master_id BETWEEN 10100 AND 15200
 --   GROUP BY finance.accounts.account_id, finance.account_masters.normally_debit
 --   ORDER BY account_master_id;


 --   --Updating credit balances of individual GL accounts.
 --   UPDATE @balance_sheet 
    --SET previous_period = trans.previous_period
    --FROM @balance_sheet AS balance_sheet
    --INNER JOIN
 --   (
 --       SELECT 
 --           @balance_sheet.account_id,         
 --           SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
 --       FROM @balance_sheet
 --       INNER JOIN finance.verified_transaction_mat_view
 --       ON finance.verified_transaction_mat_view.account_id IN
    --  (
    --      SELECT * FROM balance_sheet.child_accounts
    --  )
 --       WHERE value_date <=_previous_period
 --       AND office_id IN (SELECT * FROM core.get_office_ids(@office_id))
 --       GROUP BY balance_sheet.account_id
 --   ) AS trans
 --   ON balance_sheet.account_id = trans.account_id;

 --   --Updating credit balances of individual GL accounts.
 --   UPDATE @balance_sheet 
    --SET current_period = trans.current_period
 --   FROM @balance_sheet AS balance_sheet
    --INNER JOIN
 --   (
 --       SELECT 
 --           @balance_sheet.account_id,         
 --           SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
 --       FROM @balance_sheet
 --       INNER JOIN finance.verified_transaction_mat_view
 --       ON finance.verified_transaction_mat_view.account_id IN
    --  (
    --      SELECT * FROM balance_sheet.child_accounts
    --  )
 --       WHERE value_date <=@current_period
 --       AND office_id IN 
    --  (
    --      SELECT * FROM core.get_office_ids(@office_id)
    --  )
 --       GROUP BY @balance_sheet.account_id
 --   ) AS trans
 --   ON balance_sheet.account_id = trans.account_id;


 --   --Dividing by the factor.
 --   UPDATE @balance_sheet SET 
 --       previous_period = @balance_sheet.previous_period / @factor,
 --       current_period = @balance_sheet.current_period / @factor;

 --   --Upading balance of retained earnings
 --   UPDATE @balance_sheet SET 
 --       previous_period = finance.get_retained_earnings(@previous_period, @office_id, @factor),
 --       current_period = finance.get_retained_earnings(@current_period, @office_id, @factor)
 --   WHERE @balance_sheet.item_id = 15300;

 --   --Reversing assets to debit balance.
 --   UPDATE @balance_sheet SET 
 --       previous_period=@balance_sheet.previous_period*-1,
 --       current_period=@balance_sheet.current_period*-1 
 --   WHERE @balance_sheet.is_debit = 1;



 --   FOR this IN 
 --   SELECT * FROM @balance_sheet 
 --   WHERE COALESCE(@balance_sheet.previous_period, 0) + COALESCE(@balance_sheet.current_period, 0) != 0 
 --   AND @balance_sheet.account_id IS NOT NULL
 --   LOOP
 --       UPDATE @balance_sheet SET skip = 1 
    --  WHERE this.account_id IN(SELECT * FROM @balance_sheet.child_accounts)
 --       AND @balance_sheet.account_id != this.account_id;
 --   END LOOP;

 --   --Updating current period amount on GL parent item by the sum of their respective child balances.
 --   WITH running_totals AS
 --   (
 --       SELECT @balance_sheet.parent_item_id,
 --       SUM(COALESCE(@balance_sheet.previous_period, 0)) AS previous_period,
 --       SUM(COALESCE(@balance_sheet.current_period, 0)) AS current_period
 --       FROM @balance_sheet
 --       WHERE skip = 0
 --       AND parent_item_id IS NOT NULL
 --       GROUP BY @balance_sheet.parent_item_id
 --   )
 --   UPDATE @balance_sheet SET 
 --       previous_period = running_totals.previous_period,
 --       current_period = running_totals.current_period
 --   FROM running_totals
 --   WHERE running_totals.parent_item_id = @balance_sheet.item_id
 --   AND @balance_sheet.item_id
 --   IN
 --   (
 --       SELECT parent_item_id FROM running_totals
 --   );


 --   --Updating sum amount on parent item by the sum of their respective child balances.
 --   UPDATE @balance_sheet SET 
 --       previous_period = tran.previous_period,
 --       current_period = tran.current_period
 --   FROM 
 --   (
 --       SELECT @balance_sheet.parent_item_id,
 --       SUM(@balance_sheet.previous_period) AS previous_period,
 --       SUM(@balance_sheet.current_period) AS current_period
 --       FROM @balance_sheet
 --       WHERE @balance_sheet.parent_item_id IS NOT NULL
 --       GROUP BY @balance_sheet.parent_item_id
 --   ) 
 --   AS tran 
 --   WHERE tran.parent_item_id = @balance_sheet.item_id
 --   AND tran.parent_item_id IS NOT NULL;


 --   --Updating sum amount on grandparents.
 --   UPDATE @balance_sheet SET 
 --       previous_period = tran.previous_period,
 --       current_period = tran.current_period
 --   FROM 
 --   (
 --       SELECT @balance_sheet.parent_item_id,
 --       SUM(@balance_sheet.previous_period) AS previous_period,
 --       SUM(@balance_sheet.current_period) AS current_period
 --       FROM @balance_sheet
 --       WHERE @balance_sheet.parent_item_id IS NOT NULL
 --       GROUP BY @balance_sheet.parent_item_id
 --   ) 
 --   AS tran 
 --   WHERE tran.parent_item_id = @balance_sheet.item_id;

 --   --Removing ledgers having zero balances
 --   DELETE FROM @balance_sheet
 --   WHERE COALESCE(@balance_sheet.previous_period, 0) + COALESCE(@balance_sheet.current_period, 0) = 0
 --   AND @balance_sheet.account_id IS NOT NULL;

 --   --Converting 0's to NULLS.
 --   UPDATE @balance_sheet SET previous_period = CASE WHEN @balance_sheet.previous_period = 0 THEN NULL ELSE @balance_sheet.previous_period END;
 --   UPDATE @balance_sheet SET current_period = CASE WHEN @balance_sheet.current_period = 0 THEN NULL ELSE @balance_sheet.current_period END;
    
 --   UPDATE @balance_sheet SET sort = @balance_sheet.item_id WHERE @balance_sheet.item_id < 15400;
 --   UPDATE @balance_sheet SET sort = @balance_sheet.parent_item_id WHERE @balance_sheet.item_id >= 15400;

 --   INSERT INTO @result
 --   SELECT
 --       row_number() OVER(order by @balance_sheet.sort, @balance_sheet.item_id) AS id,
 --       @balance_sheet.item,
 --       @balance_sheet.previous_period,
 --       @balance_sheet.current_period,
 --       @balance_sheet.account_id,
 --       @balance_sheet.account_number,
 --       @balance_sheet.is_retained_earning
 --   FROM @balance_sheet;
    --TODO
    RETURN;
END;



GO


