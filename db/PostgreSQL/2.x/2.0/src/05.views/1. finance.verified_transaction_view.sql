DROP VIEW IF EXISTS finance.verified_transaction_view CASCADE;

CREATE VIEW finance.verified_transaction_view
AS
SELECT * FROM finance.transaction_view
WHERE verification_status_id > 0;
