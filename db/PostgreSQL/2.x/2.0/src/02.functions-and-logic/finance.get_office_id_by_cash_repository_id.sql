DROP FUNCTION IF EXISTS finance.get_office_id_by_cash_repository_id(integer);

CREATE FUNCTION finance.get_office_id_by_cash_repository_id(integer)
RETURNS integer
AS
$$
BEGIN
        RETURN office_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_id=$1
		AND NOT finance.cash_repositories.deleted;
END
$$
LANGUAGE plpgsql;
