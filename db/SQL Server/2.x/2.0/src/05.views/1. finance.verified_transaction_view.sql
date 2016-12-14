IF OBJECT_ID('finance.verified_transaction_view CASCADE') IS NOT NULL
DROP VIEW finance.verified_transaction_view CASCADE;

GO



CREATE VIEW finance.verified_transaction_view
AS
SELECT * FROM finance.transaction_view
WHERE verification_status_id > 0;


GO
