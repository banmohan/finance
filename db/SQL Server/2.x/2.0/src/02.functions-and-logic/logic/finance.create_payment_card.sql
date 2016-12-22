IF OBJECT_ID('finance.create_payment_card') IS NOT NULL
DROP PROCEDURE finance.create_payment_card;

GO

CREATE PROCEDURE finance.create_payment_card
(
    @payment_card_code      national character varying(12),
    @payment_card_name      national character varying(100),
    @card_type_id           integer
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT * FROM finance.payment_cards
        WHERE payment_card_code = @payment_card_code
    )
    BEGIN
        INSERT INTO finance.payment_cards(payment_card_code, payment_card_name, card_type_id)
        SELECT @payment_card_code, @payment_card_name, @card_type_id;
    END
    ELSE
    BEGIN
        UPDATE finance.payment_cards
        SET 
            payment_card_code =     @payment_card_code, 
            payment_card_name =     @payment_card_name,
            card_type_id =          @card_type_id
        WHERE
            payment_card_code =     @payment_card_code;
    END;
END;

GO

