IF OBJECT_ID('finance.account_scrud_view') IS NOT NULL
DROP VIEW finance.account_scrud_view --CASCADE;

GO



CREATE VIEW finance.account_scrud_view
AS
SELECT
    finance.accounts.account_id,
    finance.account_masters.account_master_code + ' (' + finance.account_masters.account_master_name + ')' AS account_master,
    finance.accounts.account_number,
    finance.accounts.external_code,
    core.currencies.currency_code + ' ('+ core.currencies.currency_name+ ')' currency,
    finance.accounts.account_name,
    finance.accounts.description,
    finance.accounts.confidential,
    finance.accounts.is_transaction_node,
    finance.accounts.sys_type,
    finance.accounts.account_master_id,
    parent_account.account_number + ' (' + parent_account.account_name + ')' AS parent    
FROM finance.accounts
INNER JOIN finance.account_masters
ON finance.account_masters.account_master_id=finance.accounts.account_master_id
LEFT JOIN core.currencies
ON finance.accounts.currency_code = core.currencies.currency_code
LEFT JOIN finance.accounts parent_account
ON parent_account.account_id=finance.accounts.parent_account_id
WHERE finance.accounts.deleted = 0;


GO
