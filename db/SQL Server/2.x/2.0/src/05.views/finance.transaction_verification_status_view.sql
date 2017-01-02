IF OBJECT_ID('finance.transaction_verification_status_view') IS NOT NULL
DROP VIEW finance.transaction_verification_status_view;

GO

CREATE VIEW finance.transaction_verification_status_view
AS
SELECT
    finance.transaction_master.transaction_master_id,
    finance.transaction_master.user_id,
    finance.transaction_master.office_id,
    finance.transaction_master.verification_status_id, 
    account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) AS verifier_name,
    finance.transaction_master.verified_by_user_id,
    finance.transaction_master.last_verified_on, 
    finance.transaction_master.verification_reason
FROM finance.transaction_master;

GO
