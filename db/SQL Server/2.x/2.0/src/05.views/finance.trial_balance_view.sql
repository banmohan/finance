IF OBJECT_ID('finance.trial_balance_view') IS NOT NULL
DROP VIEW finance.trial_balance_view;

GO

CREATE VIEW finance.trial_balance_view
AS
SELECT finance.get_account_name_by_account_id(account_id) AS account, 
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE NULL END) AS debit,
    SUM(CASE finance.verified_transaction_view.tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE NULL END) AS Credit
FROM finance.verified_transaction_view
GROUP BY account_id;

GO

