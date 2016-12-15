IF OBJECT_ID('finance.verified_transaction_mat_view') IS NOT NULL
DROP VIEW finance.verified_transaction_mat_view--CASCADE;

GO

CREATE  VIEW finance.verified_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_view;

GO
