IF OBJECT_ID('finance.journal_verification_policy_scrud_view') IS NOT NULL
DROP VIEW finance.journal_verification_policy_scrud_view;

GO




CREATE VIEW finance.journal_verification_policy_scrud_view
AS
SELECT
    finance.journal_verification_policy.journal_verification_policy_id,
    finance.journal_verification_policy.user_id,
    account.get_name_by_user_id(finance.journal_verification_policy.user_id) AS "user",
    finance.journal_verification_policy.office_id,
    core.get_office_name_by_office_id(finance.journal_verification_policy.office_id) AS office,
    finance.journal_verification_policy.can_verify,
    finance.journal_verification_policy.can_self_verify,
    finance.journal_verification_policy.effective_from,
    finance.journal_verification_policy.ends_on,
    finance.journal_verification_policy.is_active
FROM finance.journal_verification_policy
WHERE finance.journal_verification_policy.deleted = 0;




GO
