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
