IF OBJECT_ID('finance.account_selector_view') IS NOT NULL
DROP VIEW finance.account_selector_view;

GO



CREATE VIEW finance.account_selector_view
AS
SELECT
    finance.accounts.account_id,
    finance.accounts.account_number AS account_code,
    finance.accounts.account_name
FROM finance.accounts
WHERE finance.accounts.deleted = 0;


GO
