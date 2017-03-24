IF OBJECT_ID('finance.get_retained_earnings') IS NOT NULL
DROP FUNCTION finance.get_retained_earnings;

GO

CREATE FUNCTION finance.get_retained_earnings
(
    @date_to                        date,
    @office_id                      integer,
    @factor                         integer
)
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE     @date_from              date;
    DECLARE     @net_profit             numeric(30, 6);
    DECLARE     @paid_dividends         numeric(30, 6);

    IF(COALESCE(@factor, 0) = 0)
    BEGIN
        SET @factor = 1;
    END;
    
    SET @date_from              = finance.get_fiscal_year_start_date(@office_id);    
    SET @net_profit             = finance.get_net_profit(@date_from, @date_to, @office_id, @factor, 1);

    SELECT 
        @paid_dividends = COALESCE(SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) / @factor, 0)        
    FROM finance.verified_transaction_mat_view
    WHERE value_date <= @date_to
    AND account_master_id BETWEEN 15300 AND 15400
    AND office_id IN (SELECT * FROM core.get_office_ids(@office_id));
    
    RETURN @net_profit - @paid_dividends;
END;


GO