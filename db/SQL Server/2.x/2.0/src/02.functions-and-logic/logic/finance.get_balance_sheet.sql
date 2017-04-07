IF OBJECT_ID('finance.get_balance_sheet_assets') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet_assets;

GO

CREATE FUNCTION finance.get_balance_sheet_assets
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

	INSERT INTO @result(account_id)
	SELECT DISTINCT account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 10100 AND 10999;


    UPDATE @result 
    SET previous_period = trans.previous_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

    UPDATE @result 
    SET current_period = trans.current_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

	UPDATE @result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name, 
		account_master_id = finance.accounts.account_master_id
	FROM @result AS result 
	INNER JOIN finance.accounts
	ON finance.accounts.account_id = result.account_id;

	UPDATE @result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM @result AS result 
	INNER JOIN finance.account_masters
	ON finance.account_masters.account_master_id = result.account_master_id;

	UPDATE @result
	SET 
		current_period = current_period / @factor,
		previous_period = previous_period / @factor;

	RETURN;
END

GO

--SELECT * FROM finance.get_balance_sheet_assets('3-14-2017', '1-1-2020', 1, 1, 1);

GO

IF OBJECT_ID('finance.get_balance_sheet_liabilities') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet_liabilities;

GO

CREATE FUNCTION finance.get_balance_sheet_liabilities
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
    IF(COALESCE(@factor, 0) = 0)
	BEGIN
        SET @factor = 1;
    END;

	INSERT INTO @result(account_id)
	SELECT DISTINCT account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 15000 AND 15999
	AND finance.verified_transaction_mat_view.account_master_id NOT IN(15300, 15400); --EXCLUDE RETAINED EARNINGS


    UPDATE @result 
    SET previous_period = trans.previous_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

    UPDATE @result 
    SET current_period = trans.current_period
    FROM @result AS result
    INNER JOIN
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM @result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=@current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(@office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    ON result.account_id = trans.account_id;

	UPDATE @result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name, 
		account_master_id = finance.accounts.account_master_id
	FROM @result AS result 
	INNER JOIN finance.accounts
	ON finance.accounts.account_id = result.account_id;

	UPDATE @result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM @result AS result 
	INNER JOIN finance.account_masters
	ON finance.account_masters.account_master_id = result.account_master_id;

	UPDATE @result
	SET 
		current_period = current_period / @factor,
		previous_period = previous_period / @factor;

	RETURN;
END

GO

--SELECT * FROM finance.get_balance_sheet_liabilities('3-14-2017', '1-1-2020', 1, 1, 1);


GO

IF OBJECT_ID('finance.get_balance_sheet') IS NOT NULL
DROP FUNCTION finance.get_balance_sheet;

GO

CREATE FUNCTION finance.get_balance_sheet
(
    @previous_period                date,
    @current_period                 date,
    @user_id                        integer,
    @office_id                      integer,
    @factor                         integer
)
RETURNS @result TABLE
(
	account_id						integer,
	account_number					national character varying(200),
	account_name					national character varying(1000),
	account_master_id				integer,
	account_master_name				national character varying(1000),
	previous_period					numeric(30, 6),
	current_period					numeric(30, 6)
)
AS
BEGIN
	INSERT INTO @result
	SELECT * FROM finance.get_balance_sheet_assets(@previous_period, @current_period, @user_id, @office_id, @factor);

	INSERT INTO @result
	SELECT * FROM finance.get_balance_sheet_liabilities(@previous_period, @current_period, @user_id, @office_id, @factor);

	INSERT INTO @result(account_id, account_number, account_name, account_master_id, account_master_name, previous_period, current_period)
	SELECT NULL, '15300', account_master_name, 15999, account_master_name, finance.get_retained_earnings(@previous_period, @office_id, @factor), finance.get_retained_earnings(@current_period, @office_id, @factor)
	FROM finance.account_masters
	WHERE finance.account_masters.account_master_id = 15300;

	RETURN;
END;

GO

--SELECT * FROM finance.get_balance_sheet('3-14-2017', '1-1-2020', 1, 1, 1);


GO
