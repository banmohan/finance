IF OBJECT_ID('finance.get_verification_status_name_by_verification_status_id') IS NOT NULL
DROP FUNCTION finance.get_verification_status_name_by_verification_status_id;

GO

CREATE FUNCTION finance.get_verification_status_name_by_verification_status_id(@verification_status_id integer)
RETURNS national character varying(500)
AS

BEGIN
    RETURN
    (
	    SELECT
	        verification_status_name
	    FROM finance.verification_statuses
	    WHERE finance.verification_statuses.verification_status_id = @verification_status_id
	    AND finance.verification_statuses.deleted = 0
	);
END;




GO
