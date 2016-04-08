DROP FUNCTION IF EXISTS finance.get_date(_office_id integer);

CREATE FUNCTION finance.get_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN finance.get_value_date($1);
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_month_end_date(_office_id integer);

CREATE FUNCTION finance.get_month_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date($1);
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_month_start_date(_office_id integer);

CREATE FUNCTION finance.get_month_start_date(_office_id integer)
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
        WHERE value_date >= finance.get_value_date($1)
    );

    IF(_date IS NULL) THEN
        SELECT starts_from 
        INTO _date
        FROM finance.fiscal_year;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_quarter_end_date(_office_id integer);

CREATE FUNCTION finance.get_quarter_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date($1)
    AND frequency_id > 2;
END
$$
LANGUAGE plpgsql;



DROP FUNCTION IF EXISTS finance.get_quarter_start_date(_office_id integer);

CREATE FUNCTION finance.get_quarter_start_date(_office_id integer)
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
        WHERE value_date >= finance.get_value_date($1)
    )
    AND frequency_id > 2;

    IF(_date IS NULL) THEN
        SELECT starts_from 
        INTO _date
        FROM finance.fiscal_year;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_fiscal_half_end_date(_office_id integer);

CREATE FUNCTION finance.get_fiscal_half_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date($1)
    AND frequency_id > 3;
END
$$
LANGUAGE plpgsql;



DROP FUNCTION IF EXISTS finance.get_fiscal_half_start_date(_office_id integer);

CREATE FUNCTION finance.get_fiscal_half_start_date(_office_id integer)
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
        WHERE value_date >= finance.get_value_date($1)
    )
    AND frequency_id > 3;

    IF(_date IS NULL) THEN
        SELECT starts_from 
        INTO _date
        FROM finance.fiscal_year;
    END IF;

    RETURN _date;
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_fiscal_year_end_date(_office_id integer);

CREATE FUNCTION finance.get_fiscal_year_end_date(_office_id integer)
RETURNS date
AS
$$
BEGIN
    RETURN MIN(value_date) 
    FROM finance.frequency_setups
    WHERE value_date >= finance.get_value_date($1)
    AND frequency_id > 4;
END
$$
LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS finance.get_fiscal_year_start_date(_office_id integer);

CREATE FUNCTION finance.get_fiscal_year_start_date(_office_id integer)
RETURNS date
AS
$$
    DECLARE _date               date;
BEGIN

    SELECT starts_from 
    INTO _date
    FROM finance.fiscal_year;

    RETURN _date;
END
$$
LANGUAGE plpgsql;
