IF OBJECT_ID('finance.get_cash_repository_id_by_cash_repository_name') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_id_by_cash_repository_name;

GO

CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_name(@cash_repository_name national character varying(500))
RETURNS integer
AS

BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_name=@cash_repository_name
        AND finance.cash_repositories.deleted = 0
    );
END;




GO
