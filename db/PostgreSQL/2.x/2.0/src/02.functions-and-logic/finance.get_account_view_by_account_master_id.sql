DROP FUNCTION IF EXISTS finance.get_account_view_by_account_master_id
(
    _account_master_id      integer,
    _row_number             integer
);

CREATE FUNCTION finance.get_account_view_by_account_master_id
(
    _account_master_id      integer,
    _row_number             integer
)
RETURNS table
(
    id                      bigint,
    account_id              integer,
    account_name            text    
)
AS
$$
BEGIN
    RETURN QUERY
    SELECT ROW_NUMBER() OVER (ORDER BY accounts.account_id) +_row_number, * FROM 
    (
        SELECT finance.accounts.account_id, finance.get_account_name_by_account_id(finance.accounts.account_id)
        FROM finance.accounts
        WHERE finance.accounts.account_master_id = _account_master_id
    ) AS accounts;    
END;
$$
LANGUAGE plpgsql;
