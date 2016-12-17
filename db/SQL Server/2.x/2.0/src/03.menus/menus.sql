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


EXECUTE core.create_app 'Finance', 'Finance', '1.0', 'MixERP Inc.', 'December 1, 2015', 'book red', '/dashboard/finance/tasks/journal/entry', NULL;

EXECUTE core.create_menu 'Finance', 'Tasks', '', 'lightning', '';
EXECUTE core.create_menu 'Finance', 'Journal Entry', '/dashboard/finance/tasks/journal/entry', 'add square', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Exchange Rates', '/dashboard/finance/tasks/exchange-rates', 'exchange', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Journal Verification', '/dashboard/finance/tasks/journal/verification', 'checkmark', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Verification Policy', '/dashboard/finance/tasks/verification-policy', 'checkmark box', 'Tasks';
EXECUTE core.create_menu 'Finance', 'Auto Verification Policy', '/dashboard/finance/tasks/verification-policy/auto', 'check circle', 'Tasks';
EXECUTE core.create_menu 'Finance', 'EOD Processing', '/dashboard/finance/tasks/eod-processing', 'spinner', 'Tasks';

EXECUTE core.create_menu 'Finance', 'Setup', 'square outline', 'configure', '';
EXECUTE core.create_menu 'Finance', 'Chart of Accounts', '/dashboard/finance/setup/chart-of-accounts', 'sitemap', 'Setup';
EXECUTE core.create_menu 'Finance', 'Currencies', '/dashboard/finance/setup/currencies', 'dollar', 'Setup';
EXECUTE core.create_menu 'Finance', 'Bank Accounts', '/dashboard/finance/setup/bank-accounts', 'university', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Flow Headings', '/dashboard/finance/setup/cash-flow/headings', 'book', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Flow Setup', '/dashboard/finance/setup/cash-flow/setup', 'edit', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cost Centers', '/dashboard/finance/setup/cost-centers', 'closed captioning', 'Setup';
EXECUTE core.create_menu 'Finance', 'Cash Repositories', '/dashboard/finance/setup/cash-repositories', 'bookmark', 'Setup';

EXECUTE core.create_menu 'Finance', 'Reports', '', 'block layout', '';
EXECUTE core.create_menu 'Finance', 'Account Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/AccountStatement.xml', 'file national character varying(1000) outline', 'Reports';
EXECUTE core.create_menu 'Finance', 'Trial Balance', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/TrialBalance.xml', 'signal', 'Reports';
EXECUTE core.create_menu 'Finance', 'Profit & Loss Account', '/dashboard/finance/reports/pl-account', 'line chart', 'Reports';
EXECUTE core.create_menu 'Finance', 'Retained Earnings Statement', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/RetainedEarnings.xml', 'arrow circle down', 'Reports';
EXECUTE core.create_menu 'Finance', 'Balance Sheet', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/BalanceSheet.xml', 'calculator', 'Reports';
EXECUTE core.create_menu 'Finance', 'Cash Flow', '/dashboard/finance/reports/cash-flow', 'crosshairs', 'Reports';
EXECUTE core.create_menu 'Finance', 'Exchange Rate Report', '/dashboard/reports/view/Areas/MixERP.Finance/Reports/ExchangeRates.xml', 'options', 'Reports';


DECLARE @office_id integer = core.get_office_id_by_office_name('Default');
EXECUTE auth.create_app_menu_policy
'Admin', 
@office_id, 
'Finance',
'{*}';



GO
