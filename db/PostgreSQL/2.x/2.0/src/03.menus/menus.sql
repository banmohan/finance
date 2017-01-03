DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'Finance'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'Finance'
);

DELETE FROM core.menus
WHERE app_name = 'Finance';


SELECT * FROM core.create_app('Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/tasks/journal/entry', NULL::text[]);

SELECT * FROM core.create_menu('Finance', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('Finance', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'add square', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'exchange', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Verification Policy', '/dashboard/finance/tasks/verification-policy', 'checkmark box', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Auto Verification Policy', '/dashboard/finance/tasks/verification-policy/auto', 'check circle', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Account Reconciliation', '/dashboard/finance/tasks/account-reconciliation', 'book', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'EOD Processing', '/dashboard/finance/tasks/eod-processing', 'spinner', 'Tasks');

SELECT * FROM core.create_menu('Finance', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Finance', 'Chart of Accounts', '/dashboard/finance/setup/chart-of-accounts', 'sitemap', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Currencies', '/dashboard/finance/setup/currencies', 'dollar', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'university', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'book', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'edit', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'closed captioning', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'bookmark', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Fical Years', '/dashboard/finance/setup/fiscal-years', 'sitemap', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Frequency Setups', '/dashboard/finance/setup/frequency-setups', 'sitemap', 'Setup');

SELECT * FROM core.create_menu('Finance', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('Finance', 'Account Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/AccountStatement.xml', 'file text outline', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Trial Balance', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TrialBalance.xml', 'signal', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Profit & Loss Account', '/dashboard/finance/reports/pl-account', 'line chart', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Retained Earnings Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/RetainedEarnings.xml', 'arrow circle down', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Balance Sheet', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/BalanceSheet.xml', 'calculator', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'crosshairs', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Exchange Rate Report', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/ExchangeRates.xml', 'options', 'Reports');

SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'Finance',
    '{*}'::text[]
);

