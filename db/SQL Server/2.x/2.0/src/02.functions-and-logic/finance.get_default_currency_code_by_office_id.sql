IF OBJECT_ID('finance.get_default_currency_code_by_office_id') IS NOT NULL
DROP FUNCTION finance.get_default_currency_code_by_office_id;

GO

CREATE FUNCTION finance.get_default_currency_code_by_office_id(@office_id integer)
RETURNS national character varying(12)
AS

BEGIN
    RETURN
    (
        SELECT core.offices.currency_code 
        FROM core.offices
        WHERE core.offices.office_id = @office_id
        AND core.offices.deleted = 0    
    );
END;




GO
