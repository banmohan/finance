DROP FUNCTION IF EXISTS finance.get_balance_sheet_assets
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
);

CREATE FUNCTION finance.get_balance_sheet_assets
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
)
RETURNS TABLE
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
$$
BEGIN
    IF(COALESCE(_factor, 0) = 0) THEN
        _factor := 1;
    END IF;

    DROP TABLE IF EXISTS _result;
    CREATE TEMPORARY TABLE _result
    (
        account_id						integer,
        account_number					national character varying(200),
        account_name					national character varying(1000),
        account_master_id				integer,
        account_master_name				national character varying(1000),
        previous_period					numeric(30, 6),
        current_period					numeric(30, 6)
    ) ON COMMIT DROP;

	INSERT INTO _result(account_id)
	SELECT DISTINCT finance.verified_transaction_mat_view.account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 10100 AND 10999;


    UPDATE _result 
    SET previous_period = summary.previous_period
    FROM
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM _result AS result
        LEFT JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=_previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(_office_id)
		)
		GROUP BY result.account_id
    ) AS summary
    WHERE _result.account_id = summary.account_id;

    UPDATE _result 
    SET current_period = summary.current_period
    FROM
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Dr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM _result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=_current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(_office_id)
		)
		GROUP BY result.account_id
    ) AS summary
    WHERE _result.account_id = summary.account_id;

	UPDATE _result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name,
		account_master_id = finance.accounts.account_master_id
	FROM finance.accounts
	WHERE finance.accounts.account_id = _result.account_id;


	UPDATE _result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM finance.account_masters
	WHERE finance.account_masters.account_master_id = _result.account_master_id;

	UPDATE _result
	SET 
		current_period = _result.current_period / _factor,
		previous_period = _result.previous_period / _factor;

	RETURN QUERY
	SELECT * FROM _result;
END
$$
LANGUAGE plpgsql;



--SELECT * FROM finance.get_balance_sheet_assets('3-14-2017', '1-1-2020', 1, 1, 1);



DROP FUNCTION IF EXISTS finance.get_balance_sheet_liabilities
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
);


CREATE FUNCTION finance.get_balance_sheet_liabilities
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
)
RETURNS TABLE
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
$$
BEGIN
    IF(COALESCE(_factor, 0) = 0) THEN
        _factor := 1;
    END IF;

    DROP TABLE IF EXISTS _result;
    CREATE TEMPORARY TABLE _result
    (
        account_id						integer,
        account_number					national character varying(200),
        account_name					national character varying(1000),
        account_master_id				integer,
        account_master_name				national character varying(1000),
        previous_period					numeric(30, 6),
        current_period					numeric(30, 6)
    ) ON COMMIT DROP;

	INSERT INTO _result(account_id)
	SELECT DISTINCT finance.verified_transaction_mat_view.account_id
	FROM finance.verified_transaction_mat_view
    WHERE finance.verified_transaction_mat_view.account_master_id BETWEEN 15000 AND 15999
	AND finance.verified_transaction_mat_view.account_master_id NOT IN(15300, 15400); --EXCLUDE RETAINED EARNINGS


    UPDATE _result 
    SET previous_period = trans.previous_period
    FROM
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS previous_period
        FROM _result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=_previous_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(_office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    WHERE _result.account_id = trans.account_id;

    UPDATE _result 
    SET current_period = trans.current_period
    FROM
    (
        SELECT 
            result.account_id,         
            SUM(CASE tran_type WHEN 'Cr' THEN amount_in_local_currency ELSE amount_in_local_currency * -1 END) AS current_period
        FROM _result AS result
        INNER JOIN finance.verified_transaction_mat_view
        ON finance.verified_transaction_mat_view.account_id = result.account_id
		WHERE value_date <=_current_period
		AND office_id IN 
		(
			SELECT * FROM core.get_office_ids(_office_id)
		)
		GROUP BY result.account_id
    ) AS trans
    WHERE _result.account_id = trans.account_id;

	UPDATE _result
	SET 
		account_number = finance.accounts.account_number, 
		account_name = finance.accounts.account_name, 
		account_master_id = finance.accounts.account_master_id
	FROM finance.accounts
	WHERE finance.accounts.account_id = _result.account_id;

	UPDATE _result
	SET 
		account_master_name  = finance.account_masters.account_master_name
	FROM finance.account_masters
	WHERE finance.account_masters.account_master_id = _result.account_master_id;

	UPDATE _result
	SET 
		current_period = _result.current_period / _factor,
		previous_period = _result.previous_period / _factor;

	RETURN QUERY
	SELECT * FROM _result;
END
$$
LANGUAGE plpgsql;



--SELECT * FROM finance.get_balance_sheet_liabilities('3-14-2017', '1-1-2020', 1, 1, 1);




DROP FUNCTION IF EXISTS finance.get_balance_sheet
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
);



CREATE FUNCTION finance.get_balance_sheet
(
    _previous_period                date,
    _current_period                 date,
    _user_id                        integer,
    _office_id                      integer,
    _factor                         integer
)
RETURNS TABLE
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
$$
BEGIN
	RETURN QUERY
	SELECT * FROM finance.get_balance_sheet_assets(_previous_period, _current_period, _user_id, _office_id, _factor);

	RETURN QUERY
	SELECT * FROM finance.get_balance_sheet_liabilities(_previous_period, _current_period, _user_id, _office_id, _factor);

	RETURN QUERY
	SELECT NULL::integer, '15300'::national character varying(200), finance.account_masters.account_master_name, 15999, finance.account_masters.account_master_name, finance.get_retained_earnings(_previous_period, _office_id, _factor), finance.get_retained_earnings(_current_period, _office_id, _factor)
	FROM finance.account_masters
	WHERE finance.account_masters.account_master_id = 15300;

	RETURN;
END
$$
LANGUAGE plpgsql;




--SELECT * FROM finance.get_balance_sheet('3-14-2007', '1-1-2020', 1, 1, 1);



