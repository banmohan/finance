/*
IMPORTANT:
The table account_masters must only be translated, but not changed.        
*/
UPDATE core.offices
SET allow_transaction_posting = true;

INSERT INTO finance.cost_centers(cost_center_code, cost_center_name)
SELECT 'DEF', 'Default'                             UNION ALL
SELECT 'GEN', 'General Administration'              UNION ALL
SELECT 'HUM', 'Human Resources'                     UNION ALL
SELECT 'SCC', 'Support & Customer Care'             UNION ALL
SELECT 'GAE', 'Guest Accomodation & Entertainment'  UNION ALL
SELECT 'MKT', 'Marketing & Promotion'               UNION ALL
SELECT 'SAL', 'Sales & Billing'                     UNION ALL
SELECT 'FIN', 'Finance & Accounting';

INSERT INTO finance.cash_repositories(office_id, cash_repository_code, cash_repository_name)
SELECT core.get_office_id_by_office_name('Default'), 'CAC', 'Cash in Counter' UNION ALL
SELECT core.get_office_id_by_office_name('Default'), 'CAV', 'Cash in Vault';

INSERT INTO finance.journal_verification_policy(user_id, office_id, can_verify, verification_limit, can_self_verify, self_verification_limit, effective_from, ends_on, is_active)
SELECT
    account.users.user_id,
    core.offices.office_id,
    true,
    0,
    true,
    0,
    '1-1-2000',
    '1-1-2100',
    true
FROM account.users
CROSS JOIN core.offices
WHERE account.users.role_id = 9999;

INSERT INTO finance.auto_verification_policy(user_id, office_id, verification_limit, effective_from, ends_on, is_active)
SELECT
    account.users.user_id,
    core.offices.office_id,
    0,
    '1-1-2000',
    '1-1-2100',
    true
FROM account.users
CROSS JOIN core.offices
WHERE account.users.role_id = 9999;



INSERT INTO finance.fiscal_year (fiscal_year_code, fiscal_year_name, starts_from, ends_on, office_id) 
VALUES ('FY1617', 'FY 2016/2017', '2016-07-17'::date, '2017-07-16'::date, core.get_office_id_by_office_name('Default'));

INSERT INTO finance.frequency_setups (fiscal_year_code, frequency_setup_code, value_date, frequency_id, office_id) 
SELECT 'FY1617', 'Jul-Aug', '2016-08-16'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Aug-Sep', '2016-09-16'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Sep-Oc',  '2016-10-17'::date, 3, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Oct-Nov', '2016-11-16'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Nov-Dec', '2016-12-15'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Dec-Jan', '2017-01-14'::date, 4, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Jan-Feb', '2017-02-12'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Feb-Mar', '2017-03-14'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Mar-Apr', '2017-04-13'::date, 3, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Apr-May', '2017-05-14'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'May-Jun', '2017-06-15'::date, 2, core.get_office_id_by_office_name('Default') UNION ALL
SELECT 'FY1617', 'Jun-Jul', '2017-07-16'::date, 5, core.get_office_id_by_office_name('Default');

INSERT INTO finance.tax_setups(office_id, income_tax_rate, income_tax_account_id, sales_tax_rate, sales_tax_account_id)
SELECT office_id, 25, finance.get_account_id_by_account_number('20770'), 13, finance.get_account_id_by_account_number('20710')
FROM core.offices;


SELECT * FROM finance.create_card_type(1, 'CRC', 'Credit Card'          );
SELECT * FROM finance.create_card_type(2, 'DRC', 'Debit Card'           );
SELECT * FROM finance.create_card_type(3, 'CHC', 'Charge Card'          );
SELECT * FROM finance.create_card_type(4, 'ATM', 'ATM Card'             );
SELECT * FROM finance.create_card_type(5, 'SVC', 'Store-value Card'     );
SELECT * FROM finance.create_card_type(6, 'FLC', 'Fleet Card'           );
SELECT * FROM finance.create_card_type(7, 'GFC', 'Gift Card'            );
SELECT * FROM finance.create_card_type(8, 'SCR', 'Scrip'                );
SELECT * FROM finance.create_card_type(9, 'ELP', 'Electronic Purse'     );


SELECT * FROM finance.create_payment_card('CR-VSA', 'Visa',                1);
SELECT * FROM finance.create_payment_card('CR-AME', 'American Express',    1);
SELECT * FROM finance.create_payment_card('CR-MAS', 'MasterCard',          1);
SELECT * FROM finance.create_payment_card('DR-MAE', 'Maestro',             2);
SELECT * FROM finance.create_payment_card('DR-MAS', 'MasterCard Debit',    2);
SELECT * FROM finance.create_payment_card('DR-VSE', 'Visa Electron',       2);
SELECT * FROM finance.create_payment_card('DR-VSD', 'Visa Debit',          2);
SELECT * FROM finance.create_payment_card('DR-DEL', 'Delta',               2);



--ROLLBACK TRANSACTION;

