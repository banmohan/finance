DROP FUNCTION IF EXISTS finance.get_cash_repository_id_by_cash_repository_name(text);
CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_name(text)
RETURNS integer
AS
$$
BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_name=$1
		AND NOT finance.cash_repositories.deleted
    );
END
$$
LANGUAGE plpgsql;
