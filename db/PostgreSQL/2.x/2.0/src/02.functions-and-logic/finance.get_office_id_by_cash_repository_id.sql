DROP FUNCTION IF EXISTS finance.get_office_id_by_cash_repository_id(integer);

CREATE FUNCTION finance.get_office_id_by_cash_repository_id(integer)
RETURNS integer
AS
$$
BEGIN
        RETURN office_id
        FROM finance.cash_repositories
        WHERE cash_repository_id=$1;
END
$$
LANGUAGE plpgsql;
