IF OBJECT_ID('finance.reconcile_account') IS NOT NULL
DROP PROCEDURE finance.reconcile_account;

GO

CREATE PROCEDURE finance.reconcile_account
(
    @transaction_detail_id              bigint,
	@user_id							integer,
    @new_book_date                      date, 
    @reconciliation_memo                text
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    DECLARE @transaction_master_id      bigint;

	BEGIN TRY
		DECLARE @tran_count int = @@TRANCOUNT;
		
		IF(@tran_count= 0)
		BEGIN
			BEGIN TRANSACTION
		END;

		SELECT @transaction_master_id = finance.transaction_details.transaction_master_id 
		FROM finance.transaction_details
		WHERE finance.transaction_details.transaction_detail_id = @transaction_detail_id;

		UPDATE finance.transaction_master
		SET 
			book_date				= @new_book_date,
			audit_user_id			= @user_id,
			audit_ts				= GETUTCDATE()
		WHERE finance.transaction_master.transaction_master_id = @transaction_master_id;


		UPDATE finance.transaction_details
		SET
			book_date               = @new_book_date,
			reconciliation_memo     = @reconciliation_memo,
			audit_user_id			= @user_id,
			audit_ts				= GETUTCDATE()
		WHERE finance.transaction_details.transaction_master_id = @transaction_master_id;    
		IF(@tran_count = 0)
		BEGIN
			COMMIT TRANSACTION;
		END;
	END TRY
	BEGIN CATCH
		IF(XACT_STATE() <> 0 AND @tran_count = 0) 
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrorMessage national character varying(4000)	= ERROR_MESSAGE();
		DECLARE @ErrorSeverity int								= ERROR_SEVERITY();
		DECLARE @ErrorState int									= ERROR_STATE();
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH;
END

GO

--EXECUTE finance.reconcile_account 1, 1, '1-1-2000', 'test';
