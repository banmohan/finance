IF OBJECT_ID('finance.auto_verification_policy_scrud_view') IS NOT NULL
DROP VIEW finance.auto_verification_policy_scrud_view;

GO




CREATE VIEW finance.auto_verification_policy_scrud_view
AS
SELECT
    finance.auto_verification_policy.auto_verification_policy_id,
    finance.auto_verification_policy.user_id,
    account.get_name_by_user_id(finance.auto_verification_policy.user_id) AS "user",
    finance.auto_verification_policy.office_id,
    core.get_office_name_by_office_id(finance.auto_verification_policy.office_id) AS office,
    finance.auto_verification_policy.effective_from,
    finance.auto_verification_policy.ends_on,
    finance.auto_verification_policy.is_active
FROM finance.auto_verification_policy
WHERE finance.auto_verification_policy.deleted = 0;


GO
