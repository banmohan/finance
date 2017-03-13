DROP MATERIALIZED VIEW IF EXISTS finance.verified_cash_transaction_mat_view;

CREATE MATERIALIZED VIEW finance.verified_cash_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_mat_view
WHERE finance.verified_transaction_mat_view.transaction_master_id
IN
(
    SELECT finance.verified_transaction_mat_view.transaction_master_id 
    FROM finance.verified_transaction_mat_view
    WHERE account_master_id IN(10101, 10102) --Cash and Bank A/C
);

ALTER MATERIALIZED VIEW finance.verified_cash_transaction_mat_view
OWNER TO frapid_db_user;

CREATE UNIQUE INDEX verified_cash_transaction_mat_view_transaction_detail_id_uix
ON finance.verified_cash_transaction_mat_view(transaction_detail_id);