IF OBJECT_ID('finance.get_frequency_setup_code_by_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_code_by_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_code_by_frequency_setup_id(@frequency_setup_id integer)
RETURNS national character varying(24)
AS
BEGIN
    RETURN
    (
	    SELECT frequency_setup_code
	    FROM finance.frequency_setups
	    WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
	    AND finance.frequency_setups.deleted = 0
    );
END;

GO
