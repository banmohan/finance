DROP VIEW IF EXISTS finance.merchant_fee_setup_scrud_view CASCADE;

CREATE VIEW finance.merchant_fee_setup_scrud_view
AS
SELECT 
    finance.merchant_fee_setup.merchant_fee_setup_id,
    finance.bank_accounts.bank_name || ' (' || finance.bank_accounts.bank_account_number || ')' AS merchant_account,
    finance.payment_cards.payment_card_code || ' ( '|| finance.payment_cards.payment_card_name || ')' AS payment_card,
    finance.merchant_fee_setup.rate,
    finance.merchant_fee_setup.customer_pays_fee,
    finance.accounts.account_number || ' (' || finance.accounts.account_name || ')' As account,
    finance.merchant_fee_setup.statement_reference
FROM finance.merchant_fee_setup
INNER JOIN finance.bank_accounts
ON finance.merchant_fee_setup.merchant_account_id = finance.bank_accounts.account_id
INNER JOIN
finance.payment_cards
ON finance.merchant_fee_setup.payment_card_id = finance.payment_cards.payment_card_id
INNER JOIN
finance.accounts
ON finance.merchant_fee_setup.account_id = finance.accounts.account_id
WHERE NOT finance.merchant_fee_setup.deleted;
