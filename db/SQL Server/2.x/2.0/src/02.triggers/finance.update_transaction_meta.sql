IF OBJECT_ID('finance.update_transaction_meta_trigger') IS NOT NULL
DROP TRIGGER finance.update_transaction_meta_trigger;

GO

CREATE TRIGGER finance.update_transaction_meta_trigger
ON finance.transaction_master
AFTER INSERT
AS
BEGIN
    DECLARE @transaction_master_id          bigint;
    DECLARE @current_transaction_counter    integer;
    DECLARE @current_transaction_code       national character varying(50);
    DECLARE @value_date                     date;
    DECLARE @office_id                      integer;
    DECLARE @user_id                        integer;
    DECLARE @login_id                       bigint;


    SELECT
        @transaction_master_id                  = transaction_master_id,
        @current_transaction_counter            = transaction_counter,
        @current_transaction_code               = transaction_code,
        @value_date                             = value_date,
        @office_id                              = office_id,
        @user_id                                = "user_id",
        @login_id                               = login_id
    FROM INSERTED;

    IF(COALESCE(@current_transaction_code, '') = '')
    BEGIN
        UPDATE finance.transaction_master
        SET transaction_code = finance.get_transaction_code(@value_date, @office_id, @user_id, @login_id)
        WHERE transaction_master_id = @transaction_master_id;
    END;

    IF(COALESCE(@current_transaction_counter, 0) = 0)
    BEGIN
        UPDATE finance.transaction_master
        SET transaction_counter = finance.get_new_transaction_counter(@value_date)
        WHERE transaction_master_id = @transaction_master_id;
    END;

END;

GO
