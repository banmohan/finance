IF OBJECT_ID('finance.get_frequency_setup_end_date_by_frequency_setup_id') IS NOT NULL
DROP FUNCTION finance.get_frequency_setup_end_date_by_frequency_setup_id;

GO

CREATE FUNCTION finance.get_frequency_setup_end_date_by_frequency_setup_id(@frequency_setup_id integer)
RETURNS date
AS

BEGIN
    RETURN
    (
	    SELECT value_date
	    FROM finance.frequency_setups
	    WHERE finance.frequency_setups.frequency_setup_id = @frequency_setup_id
	    AND finance.frequency_setups.deleted = 0
    );
END;

GO
