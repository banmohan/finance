IF OBJECT_ID('finance.get_cash_repository_id_by_cash_repository_code') IS NOT NULL
DROP FUNCTION finance.get_cash_repository_id_by_cash_repository_code;

GO


CREATE FUNCTION finance.get_cash_repository_id_by_cash_repository_code(@cash_repository_code national character varying(24))
RETURNS integer
AS

BEGIN
    RETURN
    (
        SELECT cash_repository_id
        FROM finance.cash_repositories
        WHERE finance.cash_repositories.cash_repository_code=@cash_repository_code
        AND finance.cash_repositories.deleted = 0
    );
END;




GO
