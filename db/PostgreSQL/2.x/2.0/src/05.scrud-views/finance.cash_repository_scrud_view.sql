DROP VIEW IF EXISTS finance.cash_repository_scrud_view;

CREATE VIEW finance.cash_repository_scrud_view
AS
SELECT
    finance.cash_repositories.cash_repository_id,
    core.offices.office_code || ' (' || core.offices.office_name || ') ' AS office,
    finance.cash_repositories.cash_repository_code,
    finance.cash_repositories.cash_repository_name,
    parent_cash_repository.cash_repository_code || ' (' || parent_cash_repository.cash_repository_name || ') ' AS parent_cash_repository,
    finance.cash_repositories.description
FROM finance.cash_repositories
INNER JOIN core.offices
ON finance.cash_repositories.office_id = core.offices.office_id
LEFT JOIN finance.cash_repositories AS parent_cash_repository
ON finance.cash_repositories.parent_cash_repository_id = parent_cash_repository.parent_cash_repository_id
WHERE NOT finance.cash_repositories.deleted;
