IF OBJECT_ID('finance.get_new_transaction_counter') IS NOT NULL
DROP FUNCTION finance.get_new_transaction_counter;

GO

CREATE FUNCTION finance.get_new_transaction_counter(@value_date date)
RETURNS integer
AS
BEGIN
    DECLARE @ret_val integer;

    SELECT @ret_val = COALESCE(MAX(transaction_counter),0)
    FROM finance.transaction_master
    WHERE finance.transaction_master.value_date=@value_date;

    IF @ret_val IS NULL
    BEGIN
        SET @ret_val = 1;
    END
    ELSE
    BEGIN
        SET @ret_val = @ret_val + 1;
    END;

    RETURN @ret_val;
END;

GO
