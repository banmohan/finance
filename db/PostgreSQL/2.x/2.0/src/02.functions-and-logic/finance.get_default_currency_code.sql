DROP FUNCTION IF EXISTS finance.get_default_currency_code(cash_repository_id integer);

CREATE FUNCTION finance.get_default_currency_code(cash_repository_id integer)
RETURNS national character varying(12)
AS
$$
BEGIN
    RETURN
    (
        SELECT core.offices.currency_code 
        FROM finance.cash_repositories
        INNER JOIN core.offices
        ON core.offices.office_id = finance.cash_repositories.office_id
        WHERE finance.cash_repositories.cash_repository_id=$1
		AND NOT finance.cash_repositories.deleted	
    );
END
$$
LANGUAGE plpgsql;
