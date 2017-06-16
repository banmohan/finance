

IF OBJECT_ID('finance.check_parent_id_trigger') IS NOT NULL
DROP TRIGGER finance.check_parent_id_trigger;

GO

CREATE TRIGGER finance.check_parent_id_trigger
ON finance.accounts 
AFTER UPDATE
AS
BEGIN
	DECLARE @account_id					bigint
	DECLARE @parent_account_id			bigint

	SELECT 
		@account_id						= account_id,
		@parent_account_id				= parent_account_id
	FROM INSERTED;

	IF (@account_id = @parent_account_id)
		RAISERROR('Account id and parent account id cannot be same', 16, 1)
	RETURN;
END;

GO

