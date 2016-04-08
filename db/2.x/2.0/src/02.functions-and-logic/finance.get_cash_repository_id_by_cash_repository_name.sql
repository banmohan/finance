CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_name(text)
RETURNS integer
AS
$$
BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE cash_repository_name=$1
    );
END
$$
LANGUAGE plpgsql;
