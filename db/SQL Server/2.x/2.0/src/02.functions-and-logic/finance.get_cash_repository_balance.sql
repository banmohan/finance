
-->-->-- src/Frapid.Web/Areas/MixERP.Finance/db/SQL Server/2.x/2.0/src/02.functions-and-logic/finance.get_cash_repository_balance.sql --<--<--
IF OBJECT_ID('finance.get_cash_repository_balance') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_balance;

GO

CREATE FUNCTION finance.get_cash_repository_balance(@cash_repository_id integer, @currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
BEGIN
    DECLARE @debit numeric(30, 6);
    DECLARE @credit numeric(30, 6);

    SELECT @debit = COALESCE(SUM(amount_in_currency), 0)
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Dr';

    SELECT @credit = COALESCE(SUM(amount_in_currency), 0)
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=@cash_repository_id
    AND currency_code=@currency_code
    AND tran_type='Cr';

    RETURN @debit - @credit;
END;

GO
