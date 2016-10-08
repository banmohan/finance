SELECT * FROM core.create_app('Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/home', NULL::text[]);

SELECT * FROM core.create_menu('Finance', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('Finance', 'Home', '/dashboard/finance/home', 'user', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'user', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'ticket', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'food', 'Tasks');
SELECT * FROM core.create_menu('Finance', 'EOD Processing', '/dashboard/finance/tasks/eod', 'keyboard', 'Tasks');

SELECT * FROM core.create_menu('Finance', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('Finance', 'Chart of Account', '/dashboard/finance/setup/chart-of-accounts', 'users', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Currencies', '/dashboard/finance/setup/currencies', 'users', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'users', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'desktop', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'film', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'square outline', 'Setup');
SELECT * FROM core.create_menu('Finance', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'money', 'Setup');

SELECT * FROM core.create_menu('Finance', 'Reports', '', 'configure', '');
SELECT * FROM core.create_menu('Finance', 'Account Statement', '/dashboard/finance/reports/account-statement', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Trial Balance', '/dashboard/finance/reports/trial-balance', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Profit & Loss Account', '/dashboard/finance/reports/profit-and-loss-account', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Retained Earnings Statement', '/dashboard/finance/reports/retained-earnings', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Balance Sheet', '/dashboard/finance/reports/balance-sheet', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'money', 'Reports');
SELECT * FROM core.create_menu('Finance', 'Exchange Rates', '/dashboard/finance/reports/exchange-rates', 'money', 'Reports');

SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'Finance',
    '{*}'::text[]
);

