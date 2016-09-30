DROP FUNCTION IF EXISTS finance.create_payment_card
(
    _payment_card_code      national character varying(12),
    _payment_card_name      national character varying(100),
    _card_type_id           integer
);

CREATE FUNCTION finance.create_payment_card
(
    _payment_card_code      national character varying(12),
    _payment_card_name      national character varying(100),
    _card_type_id           integer
)
RETURNS void
AS
$$
BEGIN
    IF NOT EXISTS
    (
        SELECT * FROM finance.payment_cards
        WHERE payment_card_code = _payment_card_code
    ) THEN
        INSERT INTO finance.payment_cards(payment_card_code, payment_card_name, card_type_id)
        SELECT _payment_card_code, _payment_card_name, _card_type_id;
    ELSE
        UPDATE finance.payment_cards
        SET 
            payment_card_code =     _payment_card_code, 
            payment_card_name =     _payment_card_name,
            card_type_id =          _card_type_id
        WHERE
            payment_card_code =     _payment_card_code;
    END IF;
END
$$
LANGUAGE plpgsql;
