IF OBJECT_ID('finance.payment_card_scrud_view') IS NOT NULL
DROP VIEW finance.payment_card_scrud_view;

GO



CREATE VIEW finance.payment_card_scrud_view
AS
SELECT 
    finance.payment_cards.payment_card_id,
    finance.payment_cards.payment_card_code,
    finance.payment_cards.payment_card_name,
    finance.card_types.card_type_code + ' (' + finance.card_types.card_type_name + ')' AS card_type
FROM finance.payment_cards
INNER JOIN finance.card_types
ON finance.payment_cards.card_type_id = finance.card_types.card_type_id
WHERE finance.payment_cards.deleted = 0;


GO
