DROP VIEW IF EXISTS finance.account_selector_view;

CREATE VIEW finance.account_selector_view
AS
SELECT
    finance.accounts.account_id,
    finance.accounts.account_number AS account_code,
    finance.accounts.account_name
FROM finance.accounts
WHERE NOT finance.accounts.deleted;
