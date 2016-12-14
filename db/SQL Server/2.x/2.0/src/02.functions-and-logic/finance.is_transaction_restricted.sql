IF OBJECT_ID('finance.is_transaction_restricted') IS NOT NULL
DROP FUNCTION finance.is_transaction_restricted;

GO

CREATE FUNCTION finance.is_transaction_restricted
(
    @office_id      integer
)
RETURNS bit
AS
BEGIN
    RETURN
    (
	    SELECT ~ allow_transaction_posting
	    FROM core.offices
	    WHERE office_id=@office_id
    );
END;




--SELECT * FROM finance.is_transaction_restricted(1);

GO
