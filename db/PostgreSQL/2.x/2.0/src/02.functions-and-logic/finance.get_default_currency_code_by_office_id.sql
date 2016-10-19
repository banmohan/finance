DROP FUNCTION IF EXISTS finance.get_default_currency_code_by_office_id(office_id integer);

CREATE FUNCTION finance.get_default_currency_code_by_office_id(office_id integer)
RETURNS national character varying(12)
AS
$$
BEGIN
    RETURN
    (
        SELECT core.offices.currency_code 
        FROM core.offices
        WHERE core.offices.office_id = $1
		AND NOT core.offices.deleted	
    );
END
$$
LANGUAGE plpgsql;
