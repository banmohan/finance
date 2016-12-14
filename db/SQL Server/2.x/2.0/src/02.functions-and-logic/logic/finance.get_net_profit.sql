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
