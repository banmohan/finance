DROP VIEW IF EXISTS finance.verified_transaction_journal_view;

CREATE VIEW finance.verified_transaction_journal_view
AS
SELECT
    finance.verified_transaction_view.transaction_master_id,
    finance.verified_transaction_view.book,
    finance.verified_transaction_view.transaction_detail_id,
    finance.verified_transaction_view.account_id,
    finance.verified_transaction_view.account_name,
    CASE WHEN finance.verified_transaction_view.tran_type = 'Dr' THEN finance.verified_transaction_view.amount_in_local_currency ELSE 0 END AS dr,
    CASE WHEN finance.verified_transaction_view.tran_type = 'Cr' THEN finance.verified_transaction_view.amount_in_local_currency ELSE 0 END AS cr
FROM finance.verified_transaction_view;