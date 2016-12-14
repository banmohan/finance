IF OBJECT_ID('finance.get_office_id_by_cash_repository_id') IS NOT NULL
DROP FUNCTION finance.get_office_id_by_cash_repository_id;

GO

CREATE FUNCTION finance.get_office_id_by_cash_repository_id(@cash_repository_id integer)
RETURNS integer
AS

BEGIN
    RETURN
    (
	    SELECT office_id
	    FROM finance.cash_repositories
	    WHERE finance.cash_repositories.cash_repository_id=@cash_repository_id
	    AND finance.cash_repositories.deleted = 0
    );
END;




GO
