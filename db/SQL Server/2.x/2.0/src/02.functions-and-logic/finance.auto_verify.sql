IF OBJECT_ID('finance.auto_verify') IS NOT NULL
DROP PROCEDURE finance.auto_verify;

GO


CREATE PROCEDURE finance.auto_verify
(
    @tran_id        bigint,
    @office_id      integer
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @transaction_master_id          bigint= @tran_id;
    DECLARE @transaction_posted_by          integer;
    DECLARE @verifier                       integer;
    DECLARE @status                         integer = 1;
    DECLARE @reason                         national character varying(128) = 'Automatically verified';
    DECLARE @rejected                       smallint=-3;
    DECLARE @closed                         smallint=-2;
    DECLARE @withdrawn                      smallint=-1;
    DECLARE @unapproved                     smallint = 0;
    DECLARE @auto_approved                  smallint = 1;
    DECLARE @approved                       smallint=2;
    DECLARE @book                           national character varying(50);
    DECLARE @verification_limit             numeric(30, 6);
    DECLARE @posted_amount                  numeric(30, 6);
    DECLARE @has_policy                     bit= 0;
    DECLARE @voucher_date                   date;

    SELECT
        @book = finance.transaction_master.book,
        @voucher_date = finance.transaction_master.value_date,
        @transaction_posted_by = finance.transaction_master.user_id          
    FROM finance.transaction_master
    WHERE finance.transaction_master.transaction_master_id = @transaction_master_id
    AND finance.transaction_master.deleted = 0;
    
    SELECT
        @posted_amount = SUM(amount_in_local_currency)        
    FROM
        finance.transaction_details
    WHERE finance.transaction_details.transaction_master_id = @transaction_master_id
    AND finance.transaction_details.tran_type='Cr';


    SELECT
        @has_policy = 1,
        @verification_limit = verification_limit
    FROM finance.auto_verification_policy
    WHERE finance.auto_verification_policy.user_id = @transaction_posted_by
    AND finance.auto_verification_policy.office_id = @office_id
    AND finance.auto_verification_policy.is_active= 1
    AND GETUTCDATE() >= effective_from
    AND GETUTCDATE() <= ends_on
    AND finance.auto_verification_policy.deleted = 0;

    IF(@has_policy= 1)
    BEGIN
        UPDATE finance.transaction_master
        SET 
            last_verified_on = GETUTCDATE(),
            verified_by_user_id=@verifier,
            verification_status_id=@status,
            verification_reason=@reason
        WHERE
            finance.transaction_master.transaction_master_id=@transaction_master_id
        OR
            finance.transaction_master.cascading_tran_id=@transaction_master_id
        OR
        finance.transaction_master.transaction_master_id = 
        (
            SELECT cascading_tran_id
            FROM finance.transaction_master
            WHERE finance.transaction_master.transaction_master_id=@transaction_master_id 
        );
    END
    ELSE
    BEGIN
		--RAISERROR('No auto verification policy found for this user.', 13, 1);
		PRINT 'No auto verification policy found for this user.';
    END;
    RETURN;
END;

GO
