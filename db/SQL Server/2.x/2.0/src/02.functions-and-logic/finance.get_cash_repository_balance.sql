IF OBJECT_ID('finance.get_cash_repository_balance') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_balance;

GO

CREATE FUNCTION finance.get_cash_repository_balance(@cash_repository_id integer, @currency_code national character varying(12))
RETURNS dbo.money_strict2
AS
BEGIN
    DECLARE @debit dbo.money_strict2;
    DECLARE @credit dbo.money_strict2;

    SELECT COALESCE(SUM(amount_in_currency), 0) INTO @debit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Dr';

    SELECT COALESCE(SUM(amount_in_currency), 0) INTO @credit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Cr';

    RETURN @debit - @credit;
END;

GO
