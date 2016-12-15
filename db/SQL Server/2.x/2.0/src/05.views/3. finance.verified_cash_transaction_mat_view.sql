IF OBJECT_ID('finance.verified_cash_transaction_mat_view') IS NOT NULL
DROP VIEW finance.verified_cash_transaction_mat_view;

GO

CREATE VIEW finance.verified_cash_transaction_mat_view
AS
SELECT * FROM finance.verified_transaction_mat_view
WHERE finance.verified_transaction_mat_view.transaction_master_id
IN
(
    SELECT finance.verified_transaction_mat_view.transaction_master_id 
    FROM finance.verified_transaction_mat_view
    WHERE account_master_id IN(10101, 10102) --Cash and Bank A/C
);

GO
