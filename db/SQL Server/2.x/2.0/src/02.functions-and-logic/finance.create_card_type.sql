IF OBJECT_ID('finance.create_card_type') IS NOT NULL
DROP PROCEDURE finance.create_card_type;

GO

CREATE PROCEDURE finance.create_card_type
(
    @card_type_id       integer, 
    @card_type_code     national character varying(12),
    @card_type_name     national character varying(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT * FROM finance.card_types
        WHERE card_type_id = @card_type_id
    )
	BEGIN
        INSERT INTO finance.card_types(card_type_id, card_type_code, card_type_name)
        SELECT @card_type_id, @card_type_code, @card_type_name;
		
		RETURN;
	END

    UPDATE finance.card_types
    SET 
        card_type_id =      @card_type_id, 
        card_type_code =    @card_type_code, 
        card_type_name =    @card_type_name
    WHERE card_type_id =      @card_type_id;
END

GO
