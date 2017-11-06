DROP FUNCTION IF EXISTS finance.get_cash_repository_balance(_cash_repository_id integer, _currency_code national character varying(12));

CREATE FUNCTION finance.get_cash_repository_balance(_cash_repository_id integer, _currency_code national character varying(12))
RETURNS numeric(30, 6)
AS
$$
    DECLARE _debit public.money_strict2;
    DECLARE _credit public.money_strict2;
BEGIN
    SELECT COALESCE(SUM(amount_in_currency), 0::public.money_strict2) INTO _debit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=$1
    AND currency_code=$2
    AND tran_type='Dr';

    SELECT COALESCE(SUM(amount_in_currency), 0::public.money_strict2) INTO _credit
    FROM finance.verified_transaction_view
    WHERE cash_repository_id=$1
    AND currency_code=$2
    AND tran_type='Cr';

    RETURN _debit - _credit;
END
$$
LANGUAGE plpgsql;
