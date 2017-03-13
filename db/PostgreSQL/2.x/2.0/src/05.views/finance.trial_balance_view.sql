DROP MATERIALIZED VIEW IF EXISTS finance.trial_balance_view;

CREATE MATERIALIZED VIEW finance.trial_balance_view
AS
SELECT 
	account_id, 
	finance.get_account_name_by_account_id(account_id) account_name, 
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE NULL END) AS debit,
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE NULL END) AS Credit
FROM finance.verified_transaction_view
GROUP BY account_id;

ALTER MATERIALIZED VIEW finance.trial_balance_view
OWNER TO frapid_db_user;

CREATE UNIQUE INDEX trial_balance_view_account_id_uix
ON finance.trial_balance_view(account_id);
