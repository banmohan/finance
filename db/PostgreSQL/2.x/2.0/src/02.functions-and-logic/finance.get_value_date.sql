--DROP FUNCTION IF EXISTS finance.get_value_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_value_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE this            RECORD;
    DECLARE _value_date     date;
BEGIN
    SELECT * FROM finance.day_operation
    WHERE office_id = _office_id
    AND value_date =
    (
        SELECT MAX(value_date)
        FROM finance.day_operation
        WHERE office_id = _office_id
    ) INTO this;

    IF(this.day_id IS NOT NULL) THEN
        IF(this.completed) THEN
            _value_date  := this.value_date + interval '1' day;
        ELSE
            _value_date  := this.value_date;    
        END IF;
    END IF;

    IF(_value_date IS NULL) THEN
        _value_date := NOW() AT time zone config.get_server_timezone();
    END IF;
    
    RETURN _value_date;
END
$$
LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS finance.get_month_end_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_month_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(_office_id)
    AND finance.frequency_setups.office_id = _office_id;
END
$$
LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS finance.get_month_start_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_month_start_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE _date               date;
BEGIN
    SELECT MAX(value_date) + 1
    INTO _date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(_office_id)
        AND finance.frequency_setups.office_id = _office_id
    );

    IF(_date IS NULL) THEN
        SELECT starts_from 
        INTO _date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = _office_id;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS finance.get_quarter_end_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_quarter_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(_office_id)
    AND frequency_id > 2
    AND finance.frequency_setups.office_id = _office_id;
END
$$
LANGUAGE plpgsql;



--DROP FUNCTION IF EXISTS finance.get_quarter_start_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_quarter_start_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE _date               date;
BEGIN
    SELECT MAX(value_date) + 1
    INTO _date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(_office_id)
        AND finance.frequency_setups.office_id = _office_id
    )
    AND frequency_id > 2;

    IF(_date IS NULL) THEN
        SELECT starts_from INTO _date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = _office_id;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;

--DROP FUNCTION IF EXISTS finance.get_fiscal_half_end_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_fiscal_half_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date(_office_id)
    AND frequency_id > 3
    AND finance.frequency_setups.office_id = _office_id;
END
$$
LANGUAGE plpgsql;



--DROP FUNCTION IF EXISTS finance.get_fiscal_half_start_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_fiscal_half_start_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE _date               date;
BEGIN
    SELECT MAX(value_date) + 1 INTO _date
    FROM finance.frequency_setups
    WHERE value_date < 
    (
        SELECT MIN(value_date)
        FROM finance.frequency_setups
        WHERE value_date >= finance.get_value_date(_office_id)
        AND finance.frequency_setups.office_id = _office_id
    )
    AND frequency_id > 3;

    IF(_date IS NULL) THEN
        SELECT starts_from INTO _date
        FROM finance.fiscal_year
        WHERE finance.fiscal_year.office_id = _office_id;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;


--DROP FUNCTION IF EXISTS finance.get_fiscal_year_end_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_fiscal_year_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date($1)
    AND frequency_id > 4
    AND finance.frequency_setups.office_id = _office_id;
END
$$
LANGUAGE plpgsql;



--DROP FUNCTION IF EXISTS finance.get_fiscal_year_start_date(_office_id integer);

CREATE OR REPLACE FUNCTION finance.get_fiscal_year_start_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE _date               date;
BEGIN

    SELECT starts_from INTO _date
    FROM finance.fiscal_year
    WHERE finance.fiscal_year.office_id = _office_id;

    RETURN _date;
END
$$
LANGUAGE plpgsql;


--SELECT 1 AS office_id, finance.get_value_date(1::integer) AS today, finance.get_month_start_date(1::integer) AS month_start_date,finance.get_month_end_date(1::integer) AS month_end_date, finance.get_quarter_start_date(1::integer) AS quarter_start_date, finance.get_quarter_end_date(1::integer) AS quarter_end_date, finance.get_fiscal_half_start_date(1::integer) AS fiscal_half_start_date, finance.get_fiscal_half_end_date(1::integer) AS fiscal_half_end_date, finance.get_fiscal_year_start_date(1::integer) AS fiscal_year_start_date, finance.get_fiscal_year_end_date(1::integer) AS fiscal_year_end_date;