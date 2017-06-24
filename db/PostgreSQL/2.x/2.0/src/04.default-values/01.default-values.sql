INSERT INTO finance.frequencies(frequency_id, frequency_code, frequency_name)
SELECT 2, 'EOM', 'End of Month'                 UNION ALL
SELECT 3, 'EOQ', 'End of Quarter'               UNION ALL
SELECT 4, 'EOH', 'End of Half'                  UNION ALL
SELECT 5, 'EOY', 'End of Year';



INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name)
SELECT 1, 'BSA', 'Balance Sheet A/C' UNION ALL
SELECT 2, 'PLA', 'Profit & Loss A/C' UNION ALL
SELECT 3, 'OBS', 'Off Balance Sheet A/C';

INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, parent_account_master_id, normally_debit)
SELECT 10100, 'CRA', 'Current Assets',                      1,      true    UNION ALL
SELECT 10101, 'CAS', 'Cash A/C',                            10100,  true    UNION ALL
SELECT 10102, 'CAB', 'Bank A/C',                            10100,  true    UNION ALL
SELECT 10103, 'INV', 'Investments',                 		1,  	true    UNION ALL
SELECT 10110, 'ACR', 'Accounts Receivable',                 10100,  true    UNION ALL
SELECT 10200, 'FIA', 'Fixed Assets',                        1,      true    UNION ALL
SELECT 10201, 'PPE', 'Property, Plants, and Equipments',    1,      true    UNION ALL
SELECT 10300, 'OTA', 'Other Assets',                        1,      true    UNION ALL
SELECT 15000, 'CRL', 'Current Liabilities',                 1,      false   UNION ALL
SELECT 15001, 'CAP', 'Capital',                    			15000,  false   UNION ALL
SELECT 15010, 'ACP', 'Accounts Payable',                    15000,  false   UNION ALL
SELECT 15011, 'SAP', 'Salary Payable',                      15000,  false   UNION ALL
SELECT 15020, 'DEP', 'Deposit Payable',                   	15000,  false   UNION ALL
SELECT 15030, 'BBP', 'Borrowings and Bills Payable',		15000,  false   UNION ALL
SELECT 15100, 'LTL', 'Long-Term Liabilities',               1,      false   UNION ALL
SELECT 15200, 'SHE', 'Shareholders'' Equity',               1,      false   UNION ALL--RESERVES
SELECT 15300, 'RET', 'Retained Earnings',                   15200,  false   UNION ALL
SELECT 15400, 'DIP', 'Dividends Paid',                      15300,  false	UNION ALL
SELECT 15500, 'OTP', 'Other Payable',                      	15000,  false;


INSERT INTO finance.account_masters(account_master_id, account_master_code, account_master_name, parent_account_master_id, normally_debit)
SELECT 20100, 'REV', 'Revenue',                           2,        false   UNION ALL
SELECT 20200, 'NOI', 'Non Operating Income',              2,        false   UNION ALL
SELECT 20300, 'FII', 'Financial Incomes',                 2,        false   UNION ALL
SELECT 20301, 'DIR', 'Dividends Received',                20300,    false   UNION ALL
SELECT 20302, 'INI', 'Interest Incomes',                  2,        false   UNION ALL
SELECT 20310, 'CMR', 'Commissions Received',              2,        false   UNION ALL
SELECT 20350, 'OTI', 'Other Incomes',              		  2,        false   UNION ALL
SELECT 20400, 'COS', 'Cost of Sales',                     2,        true    UNION ALL
SELECT 20500, 'DRC', 'Direct Costs',                      2,        true    UNION ALL
SELECT 20600, 'ORX', 'Operating Expenses',                2,        true    UNION ALL
SELECT 20700, 'FIX', 'Financial Expenses',                2,        true    UNION ALL
SELECT 20701, 'INT', 'Interest Expenses',                 20700,    true    UNION ALL
SELECT 20710, 'OTE', 'Other Expenses',                 	  2,    	true    UNION ALL
SELECT 20800, 'ITX', 'Income Tax Expenses',               2,        true;

/*
IMPORTANT:
The table cash_flow_headings must only be translated, but not changed.        
*/
INSERT INTO finance.cash_flow_headings(cash_flow_heading_id, cash_flow_heading_code, cash_flow_heading_name, cash_flow_heading_type, is_debit)
SELECT 20001, 'CRC',    'Cash Receipts from Customers',                 'O',   true    UNION ALL
SELECT 20002, 'CPS',    'Cash Paid to Suppliers',                       'O',   false   UNION ALL
SELECT 20003, 'CPE',    'Cash Paid to Employees',                       'O',   false   UNION ALL
SELECT 20004, 'IP',     'Interest Paid',                                'O',   false   UNION ALL
SELECT 20005, 'ITP',    'Income Taxes Paid',                            'O',   false   UNION ALL
SELECT 20006, 'SUS',    'Against Suspense Accounts',                    'O',   true   UNION ALL
SELECT 30001, 'PSE',    'Proceeds from the Sale of Equipment',          'I',   true    UNION ALL
SELECT 30002, 'DR',     'Dividends Received',                           'I',   true    UNION ALL
SELECT 40001, 'DP',     'Dividends Paid',                               'F',   false;

UPDATE finance.cash_flow_headings SET is_sales=true WHERE cash_flow_heading_code='CRC';
UPDATE finance.cash_flow_headings SET is_purchase=true WHERE cash_flow_heading_code='CPS';

/*
IMPORTANT:
The table cash_flow_setup must only be translated, but not changed.
*/
INSERT INTO finance.cash_flow_setup(cash_flow_heading_id, account_master_id)
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('CRC'), finance.get_account_master_id_by_account_master_code('ACR') UNION ALL --Cash Receipts from Customers/Accounts Receivable
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('CPS'), finance.get_account_master_id_by_account_master_code('ACP') UNION ALL --Cash Paid to Suppliers/Accounts Payable
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('CPE'), finance.get_account_master_id_by_account_master_code('SAP') UNION ALL --Cash Paid to Employees/Salary Payable
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('IP'),  finance.get_account_master_id_by_account_master_code('INT') UNION ALL --Interest Paid/Interest Expenses
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('ITP'), finance.get_account_master_id_by_account_master_code('ITX') UNION ALL --Income Taxes Paid/Income Tax Expenses
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('PSE'), finance.get_account_master_id_by_account_master_code('PPE') UNION ALL --Proceeds from the Sale of Equipment/Property, Plants, and Equipments
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('DR'),  finance.get_account_master_id_by_account_master_code('DIR') UNION ALL --Dividends Received/Dividends Received
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('DP'),  finance.get_account_master_id_by_account_master_code('DIP') UNION ALL --Dividends Paid/Dividends Paid

--We cannot guarantee that every transactions posted is 100% correct and falls under the above-mentioned categories.
--The following is the list of suspense accounts, cash entries posted directly against all other account masters.
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('BSA') UNION ALL --Against Suspense Accounts/Balance Sheet A/C
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('PLA') UNION ALL --Against Suspense Accounts/Profit & Loss A/C
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('CRA') UNION ALL --Against Suspense Accounts/Current Assets
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('FIA') UNION ALL --Against Suspense Accounts/Fixed Assets
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('OTA') UNION ALL --Against Suspense Accounts/Other Assets
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('CRL') UNION ALL --Against Suspense Accounts/Current Liabilities
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('LTL') UNION ALL --Against Suspense Accounts/Long-Term Liabilities
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('SHE') UNION ALL --Against Suspense Accounts/Shareholders' Equity
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('RET') UNION ALL --Against Suspense Accounts/Retained Earning
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('REV') UNION ALL --Against Suspense Accounts/Revenue
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('NOI') UNION ALL --Against Suspense Accounts/Non Operating Income
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('FII') UNION ALL --Against Suspense Accounts/Financial Incomes
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('COS') UNION ALL --Against Suspense Accounts/Cost of Sales
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('DRC') UNION ALL --Against Suspense Accounts/Direct Costs
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('ORX') UNION ALL --Against Suspense Accounts/Operating Expenses
SELECT finance.get_cash_flow_heading_id_by_cash_flow_heading_code('SUS'), finance.get_account_master_id_by_account_master_code('FIX');          --Against Suspense Accounts/Financial Expenses

ALTER TABLE finance.accounts
ALTER column currency_code DROP NOT NULL;

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 1,     '10000', 'Assets',                                                      TRUE,  finance.get_account_id_by_account_name('Balance Sheet A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10001', 'Current Assets',                                              TRUE,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10100', 'Cash at Bank A/C',                                            TRUE,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10110', 'Regular Checking Account',                                    FALSE, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10120', 'Payroll Checking Account',                                    FALSE, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10130', 'Savings Account',                                             FALSE, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10102, '10140', 'Special Account',                                             FALSE, finance.get_account_id_by_account_name('Cash at Bank A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10101, '10200', 'Cash in Hand A/C',                                            TRUE,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10300', 'Investments',                                                 FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10301', 'Loan & Advances',                                       	  FALSE, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10310', 'Short Term Investment',                                       FALSE, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10320', 'Other Investments',                                           FALSE, finance.get_account_id_by_account_name('Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10321', 'Investments-Money Market',                                    FALSE, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10322', 'Bank Deposit Contract (Fixed Deposit)',                       FALSE, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10103, '10323', 'Investments-Certificates of Deposit',                         FALSE, finance.get_account_id_by_account_name('Other Investments');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10110, '10400', 'Accounts Receivable',                                         FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10500', 'Other Receivables',                                           FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10501', 'Purchase Return (Receivables)',                               FALSE, finance.get_account_id_by_account_name('Other Receivables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10600', 'Loan Loss Allowances',                             TRUE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10601', 'Net Loan Loss Allowances',                             TRUE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10700', 'Inventory',                                                   TRUE,  finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10720', 'Raw Materials Inventory',                                     TRUE,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10730', 'Supplies Inventory',                                          TRUE,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10740', 'Work in Progress Inventory',                                  TRUE,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10750', 'Finished Goods Inventory',                                    TRUE,  finance.get_account_id_by_account_name('Inventory');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10800', 'Prepaid Expenses',                                            FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '10900', 'Employee Advances',                                           FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11000', 'Notes Receivable-Current',                                    FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11100', 'Prepaid Interest',                                            FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11200', 'Accrued Incomes (Assets)',                                    FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11300', 'Other Debtors',                                               FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10100, '11400', 'Other Current Assets',                                        FALSE, finance.get_account_id_by_account_name('Current Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12001', 'Noncurrent Assets',                                           TRUE,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12100', 'Furniture and Fixtures',                                      FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10201, '12200', 'Plants & Equipments',                                         FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12300', 'Rental Property',                                             FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12400', 'Vehicles',                                                    FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12500', 'Intangibles',                                                 FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12600', 'Other Depreciable Properties',                                FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12700', 'Leasehold Improvements',                                      FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12800', 'Buildings',                                                   FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '12900', 'Building Improvements',                                       FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13000', 'Interior Decorations',                                        FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13100', 'Land',                                                        FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13300', 'Trade Debtors',                                               FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13400', 'Rental Debtors',                                              FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13500', 'Staff Debtors',                                               FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13600', 'Other Noncurrent Debtors',                                    FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13700', 'Other Financial Assets',                                      FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13710', 'Deposits Held',                                               FALSE, finance.get_account_id_by_account_name('Other Financial Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13800', 'Accumulated Depreciations',                                   FALSE, finance.get_account_id_by_account_name('Noncurrent Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13810', 'Accumulated Depreciation-Furniture and Fixtures',             FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13820', 'Accumulated Depreciation-Equipment',                          FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13830', 'Accumulated Depreciation-Vehicles',                           FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13840', 'Accumulated Depreciation-Other Depreciable Properties',       FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13850', 'Accumulated Depreciation-Leasehold',                          FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13860', 'Accumulated Depreciation-Buildings',                          FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13870', 'Accumulated Depreciation-Building Improvements',              FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10200, '13880', 'Accumulated Depreciation-Interior Decorations',               FALSE, finance.get_account_id_by_account_name('Accumulated Depreciations');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14001', 'Other Assets',                                                TRUE,  finance.get_account_id_by_account_name('Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14100', 'Other Assets-Deposits',                                       FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14200', 'Other Assets-Organization Costs',                             FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14300', 'Other Assets-Accumulated Amortization-Organization Costs',    FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14400', 'Notes Receivable-Non-current',                                FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14500', 'Other Non-current Assets',                                    FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 10300, '14600', 'Non-financial Assets',                                        FALSE, finance.get_account_id_by_account_name('Other Assets');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 1,     '20000', 'Liabilities',                                                 TRUE,  finance.get_account_id_by_account_name('Balance Sheet A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20001', 'Current Liabilities',                                         TRUE,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15001, '20010', 'Shareholders',                                            FALSE, finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15010, '20100', 'Accounts Payable',                                            FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20110', 'Shipping Charge Payable',                                     FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20200', 'Accrued Expenses',                                            FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20300', 'Wages Payable',                                               FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20400', 'Deductions Payable',                                          FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20500', 'Health Insurance Payable',                                    FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20600', 'Superannuation Payable',                                      FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20700', 'Tax Payables',                                                FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20701', 'Sales Return (Payables)',                                     FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20710', 'Sales Tax Payable',                                           FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20720', 'Federal Payroll Taxes Payable',                               FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20730', 'FUTA Tax Payable',                                            FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20740', 'State Payroll Taxes Payable',                                 FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20750', 'SUTA Payable',                                                FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20760', 'Local Payroll Taxes Payable',                                 FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20770', 'Income Taxes Payable',                                        FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20780', 'Other Taxes Payable',                                         FALSE, finance.get_account_id_by_account_name('Tax Payables');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20800', 'Employee Benefits Payable',                                   FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20810', 'Provision for Annual Leave',                                  FALSE, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20820', 'Provision for Long Service Leave',                            FALSE, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20830', 'Provision for Personal Leave',                                FALSE, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20840', 'Provision for Health Leave',                                  FALSE, finance.get_account_id_by_account_name('Employee Benefits Payable');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '20900', 'Current Portion of Long-term Debt',                           FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21000', 'Advance Incomes',                                             FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21010', 'Advance Sales Income',                                        FALSE, finance.get_account_id_by_account_name('Advance Incomes');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21020', 'Grant Received in Advance',                                   FALSE, finance.get_account_id_by_account_name('Advance Incomes');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21100', 'Deposits from Customers',                                     FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21200', 'Other Current Liabilities',                                   FALSE, finance.get_account_id_by_account_name('Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21210', 'Short Term Loan Payables',                                    FALSE, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21220', 'Short Term Hire-purchase Payables',                           FALSE, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21230', 'Short Term Lease Liability',                                  FALSE, finance.get_account_id_by_account_name('Other Current Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15000, '21240', 'Grants Repayable',                                            FALSE, finance.get_account_id_by_account_name('Other Current Liabilities');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21300', 'Deposits Payable',                                    		  FALSE, finance.get_account_id_by_account_name('Current Liabilities');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21310', 'Current Deposits Payable',                                    FALSE, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21320', 'Call Deposits Payable',                                       FALSE, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21330', 'Recurring Deposits Payable',                                  FALSE, finance.get_account_id_by_account_name('Deposits Payable');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15020, '21340', 'Term Deposits Payable',                                      FALSE, finance.get_account_id_by_account_name('Deposits Payable');



INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24001', 'Noncurrent Liabilities',                                      TRUE,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24100', 'Notes Payable',                                               FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24200', 'Land Payable',                                                FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24300', 'Equipment Payable',                                           FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24400', 'Vehicles Payable',                                            FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24500', 'Lease Liability',                                             FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24600', 'Loan Payable',                                                FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24610', 'Interest Payable',                                            FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24700', 'Hire-purchase Payable',                                       FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24800', 'Bank Loans Payable',                                          FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '24900', 'Deferred Revenue',                                            FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '25000', 'Other Long-term Liabilities',                                 FALSE, finance.get_account_id_by_account_name('Noncurrent Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15100, '25010', 'Long Term Employee Benefit Provision',                        FALSE, finance.get_account_id_by_account_name('Other Long-term Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28001', 'Equity',                                                      TRUE,  finance.get_account_id_by_account_name('Liabilities');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28100', 'Stated Capital',                                              FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28110', 'Founder Capital',                                             FALSE, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28120', 'Promoter Capital',                                            FALSE, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28130', 'Member Capital',                                              FALSE, finance.get_account_id_by_account_name('Stated Capital');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28200', 'Capital Surplus',                                             FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28210', 'Share Premium',                                               FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28220', 'Capital Redemption Reserves',                                 FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28230', 'Statutory Reserves',                                          FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28240', 'Asset Revaluation Reserves',                                  FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28250', 'Exchange Rate Fluctuation Reserves',                          FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28260', 'Capital Reserves Arising From Merger',                        FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28270', 'Capital Reserves Arising From Acuisition',                    FALSE, finance.get_account_id_by_account_name('Capital Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28300', 'Retained Surplus',                                            TRUE,  finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28310', 'Accumulated Profits',                                         FALSE, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15300, '28320', 'Accumulated Losses',                                          FALSE, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15400, '28330', 'Dividends Declared (Common Stock)',                           FALSE, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15400, '28340', 'Dividends Declared (Preferred Stock)',                        FALSE, finance.get_account_id_by_account_name('Retained Surplus');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28400', 'Treasury Stock',                                              FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28500', 'Current Year Surplus',                                        FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28600', 'General Reserves',                                            FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28700', 'Other Reserves',                                              FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28800', 'Dividends Payable (Common Stock)',                            FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 15200, '28900', 'Dividends Payable (Preferred Stock)',                         FALSE, finance.get_account_id_by_account_name('Equity');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '30000', 'Revenues',                                                    TRUE,  finance.get_account_id_by_account_name('Profit and Loss A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30100', 'Sales A/C',                                                  FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20302,  '30200', 'Interest Incomes',                                           FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30210', 'Late Fee Incomes',                                           FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30220', 'Penalty Incomes',                                            FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30230', 'Admission Fees',                                             FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20350,  '30240', 'Other Fees & Charges',                                       FALSE, finance.get_account_id_by_account_name('Revenues');

INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30300', 'Other Income',                                               FALSE, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30400', 'Finance Charge Income',                                      FALSE, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30500', 'Shipping Charges Reimbursed',                                FALSE, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30600', 'Sales Returns and Allowances',                               FALSE, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20100,  '30700', 'Purchase Discounts',                                         FALSE, finance.get_account_id_by_account_name('Revenues');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '40000', 'Expenses',                                                    TRUE,  finance.get_account_id_by_account_name('Profit and Loss A/C');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 2,     '40100', 'Purchase A/C',                                                FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20400,  '40200', 'Cost of Goods Sold',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40205', 'Product Cost',                                               FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40210', 'Raw Material Purchases',                                     FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40215', 'Direct Labor Costs',                                         FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40220', 'Indirect Labor Costs',                                       FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40225', 'Heat and Power',                                             FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40230', 'Commissions',                                                FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40235', 'Miscellaneous Factory Costs',                                FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40240', 'Cost of Goods Sold-Salaries and Wages',                      FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40245', 'Cost of Goods Sold-Contract Labor',                          FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40250', 'Cost of Goods Sold-Freight',                                 FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40255', 'Cost of Goods Sold-Other',                                   FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40260', 'Inventory Adjustments',                                      FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40265', 'Purchase Returns and Allowances',                            FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20500,  '40270', 'Sales Discounts',                                            FALSE, finance.get_account_id_by_account_name('Cost of Goods Sold');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40300', 'General Purchase Expenses',                                  FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40400', 'Advertising Expenses',                                       FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40500', 'Amortization Expenses',                                      FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40600', 'Auto Expenses',                                              FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40700', 'Bad Debt Expenses',                                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '40800', 'Bank Fees',                                                  FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '40900', 'Cash Over and Short',                                        FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41000', 'Charitable Contributions Expenses',                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '41100', 'Commissions and Fees Expenses',                              FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41200', 'Depreciation Expenses',                                      FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41300', 'Dues and Subscriptions Expenses',                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41400', 'Employee Benefit Expenses',                                  FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41410', 'Employee Benefit Expenses-Health Insurance',                 FALSE, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41420', 'Employee Benefit Expenses-Pension Plans',                    FALSE, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41430', 'Employee Benefit Expenses-Profit Sharing Plan',              FALSE, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41440', 'Employee Benefit Expenses-Other',                            FALSE, finance.get_account_id_by_account_name('Employee Benefit Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41500', 'Freight Expenses',                                           FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41600', 'Gifts Expenses',                                             FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41700', 'Income Tax Expenses',                                        FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41710', 'Income Tax Expenses-Federal',                                FALSE, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41720', 'Income Tax Expenses-State',                                  FALSE, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20800,  '41730', 'Income Tax Expenses-Local',                                  FALSE, finance.get_account_id_by_account_name('Income Tax Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41800', 'Insurance Expenses',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41810', 'Insurance Expenses-Product Liability',                       FALSE, finance.get_account_id_by_account_name('Insurance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '41820', 'Insurance Expenses-Vehicle',                                 FALSE, finance.get_account_id_by_account_name('Insurance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20701,  '41900', 'Interest Expenses',                                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42000', 'Laundry and Dry Cleaning Expenses',                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42100', 'Legal and Professional Expenses',                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42200', 'Licenses Expenses',                                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42300', 'Loss on NSF Checks',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42400', 'Maintenance Expenses',                                       FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42500', 'Meals and Entertainment Expenses',                           FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42600', 'Office Expenses',                                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42700', 'Payroll Tax Expenses',                                       FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20700,  '42800', 'Penalties and Fines Expenses',                               FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '42900', 'Other Tax Expenses',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43000', 'Postage Expenses',                                           FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43100', 'Rent or Lease Expenses',                                     FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43200', 'Repair and Maintenance Expenses',                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43210', 'Repair and Maintenance Expenses-Office',                     FALSE, finance.get_account_id_by_account_name('Repair and Maintenance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43220', 'Repair and Maintenance Expenses-Vehicle',                    FALSE, finance.get_account_id_by_account_name('Repair and Maintenance Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43300', 'Supplies Expenses-Office',                                   FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43400', 'Telephone Expenses',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43500', 'Training Expenses',                                          FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43600', 'Travel Expenses',                                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43700', 'Salary Expenses',                                            FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43800', 'Wages Expenses',                                             FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '43900', 'Utilities Expenses',                                         FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '44000', 'Other Expenses',                                             FALSE, finance.get_account_id_by_account_name('Expenses');
INSERT INTO finance.accounts(account_master_id,account_number,account_name, sys_type, parent_account_id) 
SELECT 20600,  '44100', 'Gain/Loss on Sale of Assets',                                FALSE, finance.get_account_id_by_account_name('Expenses');


UPDATE finance.accounts
SET currency_code='USD';

ALTER TABLE finance.accounts
ALTER column currency_code SET NOT NULL;



