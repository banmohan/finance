IF OBJECT_ID('finance.bank_account_scrud_view') IS NOT NULL
DROP VIEW finance.bank_account_scrud_view;

GO



CREATE VIEW finance.bank_account_scrud_view
AS
SELECT 
    finance.bank_accounts.bank_account_id,
    finance.bank_accounts.account_id,
    account.users.name AS maintained_by,
    core.offices.office_code + '(' + core.offices.office_name+')' AS office_name,
    finance.bank_accounts.bank_name,
    finance.bank_accounts.bank_branch,
    finance.bank_accounts.bank_contact_number,
    finance.bank_accounts.bank_account_number,
    finance.bank_accounts.bank_account_type,
    finance.bank_accounts.relationship_officer_name
FROM finance.bank_accounts
INNER JOIN account.users
ON finance.bank_accounts.maintained_by_user_id = account.users.user_id
INNER JOIN core.offices
ON finance.bank_accounts.office_id = core.offices.office_id
WHERE finance.bank_accounts.deleted = 0;

GO
