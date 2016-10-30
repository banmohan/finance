DROP FUNCTION IF EXISTS finance.is_transaction_restricted
(
    _office_id      integer
);

CREATE FUNCTION finance.is_transaction_restricted
(
    _office_id      integer
)
RETURNS boolean
STABLE
AS
$$
BEGIN
    RETURN NOT allow_transaction_posting
    FROM core.offices
    WHERE office_id=$1;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM finance.is_transaction_restricted(1);