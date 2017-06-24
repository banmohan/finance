DELETE FROM auth.menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Finance'
);

DELETE FROM auth.group_menu_access_policy
WHERE menu_id IN
(
    SELECT menu_id FROM core.menus
    WHERE app_name = 'MixERP.Finance'
);

DELETE FROM core.menus
WHERE app_name = 'MixERP.Finance';


SELECT * FROM core.create_app('MixERP.Finance', 'Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/tasks/journal/entry', NULL::text[]);

SELECT * FROM core.create_menu('MixERP.Finance', 'Tasks', 'Tasks', '', 'lightning', '');
SELECT * FROM core.create_menu('MixERP.Finance', 'JournalEntry', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'add square', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'ExchangeRates', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'exchange', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'JournalVerification', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'checkmark', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'VerificationPolicy', 'Verification Policy', '/dashboard/finance/tasks/verification-policy', 'checkmark box', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'AutoVerificationPolicy', 'Auto Verification Policy', '/dashboard/finance/tasks/verification-policy/auto', 'check circle', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'AccountReconciliation', 'Account Reconciliation', '/dashboard/finance/tasks/account-reconciliation', 'book', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'EODProcessing', 'EOD Processing', '/dashboard/finance/tasks/eod-processing', 'spinner', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'RefreshMaterializedViews', 'Refresh Materialized Views', '/dashboard/finance/tasks/refresh-materialized-views', 'refresh', 'Tasks');
SELECT * FROM core.create_menu('MixERP.Finance', 'ImportTransactions', 'Import Transactions', '/dashboard/finance/tasks/import-transactions', 'upload', 'Tasks');

SELECT * FROM core.create_menu('MixERP.Finance', 'Setup', 'Setup', 'square outline', 'configure', '');
SELECT * FROM core.create_menu('MixERP.Finance', 'ChartOfAccounts', 'Chart of Accounts', '/dashboard/finance/setup/chart-of-accounts', 'sitemap', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'Currencies', 'Currencies', '/dashboard/finance/setup/currencies', 'dollar', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'BankAccounts', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'university', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'CashFlowHeadings', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'book', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'CashFlowSetup', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'edit', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'CostCenters', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'closed captioning', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'CashRepositories', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'bookmark', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'FiscalYears', 'Fiscal Years', '/dashboard/finance/setup/fiscal-years', 'sitemap', 'Setup');
SELECT * FROM core.create_menu('MixERP.Finance', 'FrequencySetups', 'Frequency Setups', '/dashboard/finance/setup/frequency-setups', 'sitemap', 'Setup');

SELECT * FROM core.create_menu('MixERP.Finance', 'Reports', 'Reports', '', 'block layout', '');
SELECT * FROM core.create_menu('MixERP.Finance', 'AccountStatement', 'Account Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/AccountStatement.xml', 'file text outline', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'TrialBalance', 'Trial Balance', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TrialBalance.xml', 'signal', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'TransactionSummary', 'Transaction Summary', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TransactionSummary.xml', 'signal', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'ProfitAndLossAccount', 'Profit & Loss Account', '/dashboard/finance/reports/pl-account', 'line chart', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'RetainedEarningsStatement', 'Retained Earnings Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/RetainedEarnings.xml', 'arrow circle down', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'BalanceSheet', 'Balance Sheet', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/BalanceSheet.xml', 'calculator', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'CashFlow', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'crosshairs', 'Reports');
SELECT * FROM core.create_menu('MixERP.Finance', 'ExchangeRateReport', 'Exchange Rate Report', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/ExchangeRates.xml', 'options', 'Reports');

SELECT * FROM auth.create_app_menu_policy
(
    'Admin', 
    core.get_office_id_by_office_name('Default'), 
    'MixERP.Finance',
    '{*}'::text[]
);

