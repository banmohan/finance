IF OBJECT_ID('finance.can_post_transaction') IS NOT NULL
DROP FUNCTION finance.can_post_transaction;

GO

CREATE FUNCTION finance.can_post_transaction(@login_id bigint, @user_id integer, @office_id integer, @transaction_book national character varying(50), @value_date date)
RETURNS @result TABLE
(
	can_post_transaction						bit,
	error_message								national character varying(1000)
)
AS
BEGIN
	INSERT INTO @result
	SELECT 0, '';

    DECLARE @eod_required                       bit		= finance.eod_required(@office_id);
    DECLARE @fiscal_year_start_date             date    = finance.get_fiscal_year_start_date(@office_id);
    DECLARE @fiscal_year_end_date               date    = finance.get_fiscal_year_end_date(@office_id);

	IF(@value_date IS NULL)
	BEGIN
		UPDATE @result
		SET error_message =  'Invalid value date.';
		RETURN;	
	END;
	
    IF(account.is_valid_login_id(@login_id) = 0)
    BEGIN
		UPDATE @result
		SET error_message =  'Invalid LoginId.';
		RETURN;
    END; 

    IF(core.is_valid_office_id(@office_id) = 0)
    BEGIN
        UPDATE @result
		SET error_message =  'Invalid OfficeId.';
		RETURN;
    END;

    IF(finance.is_transaction_restricted(@office_id) = 1)
    BEGIN
        UPDATE @result
		SET error_message = 'This establishment does not allow transaction posting.';
		RETURN;
    END;
    
    IF(@eod_required = 1)
    BEGIN
        IF(finance.is_restricted_mode() = 1)
        BEGIN
            UPDATE @result
			SET error_message = 'Cannot post transaction during restricted transaction mode.';
			RETURN;
        END;

        IF(@value_date < finance.get_value_date(@office_id))
        BEGIN
            UPDATE @result
			SET error_message = 'Past dated transactions are not allowed.';
			RETURN;
        END;
    END;

    IF(@value_date < @fiscal_year_start_date)
    BEGIN
        UPDATE @result
		SET error_message = 'You cannot post transactions before the current fiscal year start date.';
		RETURN;
    END;

    IF(@value_date > @fiscal_year_end_date)
    BEGIN
        UPDATE @result
		SET error_message = 'You cannot post transactions after the current fiscal year end date.';

		RETURN;
    END;
    
    IF NOT EXISTS 
    (
        SELECT *
        FROM account.users
        INNER JOIN account.roles
        ON account.users.role_id = account.roles.role_id
        AND user_id = @user_id
    )
    BEGIN
        UPDATE @result
		SET error_message = 'Access is denied. You are not authorized to post this transaction.';
    END;
	
	UPDATE @result SET error_message = '', can_post_transaction = 1;

    RETURN;
END;

GO
