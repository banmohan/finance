IF OBJECT_ID('finance.verify_transaction') IS NOT NULL
DROP PROCEDURE finance.verify_transaction;

GO

CREATE PROCEDURE finance.verify_transaction
(
    @transaction_master_id                  bigint,
    @office_id                              integer,
    @user_id                                integer,
    @login_id                               bigint,
    @verification_status_id                 smallint,
    @reason                                 national character varying(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @transaction_posted_by          integer;
    DECLARE @book                           national character varying(50);
    DECLARE @can_verify                     bit;
    DECLARE @verification_limit             numeric(30, 6);
    DECLARE @can_self_verify                bit;
    DECLARE @self_verification_limit        numeric(30, 6);
    DECLARE @posted_amount                  numeric(30, 6);
    DECLARE @has_policy                     bit= 0;
    DECLARE @journal_date                   date;
    DECLARE @journal_office_id              integer;
    DECLARE @cascading_tran_id              bigint;

    SELECT
        @book                   = finance.transaction_master.book,
        @journal_date           = finance.transaction_master.value_date,
        @journal_office_id      = finance.transaction_master.office_id,
        @transaction_posted_by  = finance.transaction_master.user_id          
    FROM
    finance.transaction_master
    WHERE finance.transaction_master.transaction_master_id=@transaction_master_id
    AND finance.transaction_master.deleted = 0;


    IF(@journal_office_id <> @office_id)
    BEGIN
        RAISERROR('Access is denied. You cannot verify a transaction of another office.', 13, 1);
    END;
        
    SELECT @posted_amount = SUM(amount_in_local_currency)
    FROM finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = @transaction_master_id
    AND finance.transaction_details.tran_type='Cr';


    SELECT
        @has_policy                 = 1,
        @can_verify                 = can_verify,
        @verification_limit         = verification_limit,
        @can_self_verify            = can_self_verify,
        @self_verification_limit    = self_verification_limit
    FROM finance.journal_verification_policy
    WHERE finance.journal_verification_policy.user_id=@user_id
    AND finance.journal_verification_policy.office_id = @office_id
    AND finance.journal_verification_policy.is_active= 1
    AND GETUTCDATE() >= effective_from
    AND GETUTCDATE() <= ends_on
    AND finance.journal_verification_policy.deleted = 0;

    IF(@can_self_verify = 0 AND @user_id = @transaction_posted_by)
    BEGIN
        SET @can_verify = 0;
    END;

    IF(@has_policy = 1)
    BEGIN
        IF(@can_verify = 1)
        BEGIN
        
            SELECT @cascading_tran_id = cascading_tran_id
            FROM finance.transaction_master
            WHERE finance.transaction_master.transaction_master_id=@transaction_master_id
            AND finance.transaction_master.deleted = 0;
            
            UPDATE finance.transaction_master
            SET 
                last_verified_on = GETUTCDATE(),
                verified_by_user_id=@user_id,
                verification_status_id=@verification_status_id,
                verification_reason=@reason
            WHERE
                finance.transaction_master.transaction_master_id=@transaction_master_id
            OR 
                finance.transaction_master.cascading_tran_id =@transaction_master_id
            OR
            finance.transaction_master.transaction_master_id = @cascading_tran_id;


            IF(COALESCE(@cascading_tran_id, 0) = 0)
            BEGIN
                SELECT @cascading_tran_id = transaction_master_id
                FROM finance.transaction_master
                WHERE finance.transaction_master.cascading_tran_id=@transaction_master_id
                AND finance.transaction_master.deleted = 0;
            END;
            
            SELECT COALESCE(@cascading_tran_id, 0);
            RETURN;
        END
        ELSE
        BEGIN
            RAISERROR('Please ask someone else to verify your transaction.', 13, 1);
        END;
    END
    ELSE
    BEGIN
        RAISERROR('No verification policy found for this user.', 13, 1);
    END;

    SELECT 0;
    RETURN;
END;

GO
