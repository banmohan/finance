IF OBJECT_ID('finance.get_transaction_code') IS NOT NULL
DROP FUNCTION finance.get_transaction_code;

GO
CREATE FUNCTION finance.get_transaction_code(@value_date date, @office_id integer, @user_id integer, @login_id bigint)
RETURNS national character varying(24)
AS
BEGIN
    DECLARE @ret_val national character varying(1000);  

    @ret_val= finance.get_new_transaction_counter(@value_date) + '-' + CONVERT(varchar(10), @value_date, 120) + '-' + CAST(@office_id varchar(100)) + '-' + CAST(@user_id varchar(100)) + '-' + CAST(@login_id varchar(100))   + '-' +  CONVERT(VARCHAR(10), GETDATE(), 108);
    RETURN @ret_val;
END;





GO
