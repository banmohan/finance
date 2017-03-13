DROP MATERIALIZED VIEW IF EXISTS finance.verified_transaction_mat_view CASCADE;

CREATE MATERIALIZED VIEW finance.verified_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_view;

ALTER MATERIALIZED VIEW finance.verified_transaction_mat_view
OWNER TO frapid_db_user;


CREATE UNIQUE INDEX verified_transaction_mat_view_transaction_detail_id_uix
ON finance.verified_transaction_mat_view(transaction_detail_id);
