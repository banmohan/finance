DROP FUNCTION IF EXISTS finance.get_exchange_rate(office_id integer, currency_code national character varying(12));

CREATE FUNCTION finance.get_exchange_rate(office_id integer, currency_code national character varying(12))
RETURNS decimal_strict2
AS
$$
    DECLARE _local_currency_code national character varying(12)= '';
    DECLARE _unit integer_strict2 = 0;
    DECLARE _exchange_rate decimal_strict2=0;
BEGIN
    SELECT core.offices.currency_code
    INTO _local_currency_code
    FROM core.offices
    WHERE core.offices.office_id=$1;

    IF(_local_currency_code = $2) THEN
        RETURN 1;
    END IF;

    SELECT unit, exchange_rate
    INTO _unit, _exchange_rate
    FROM finance.exchange_rate_details
    INNER JOIN finance.exchange_rates
    ON finance.exchange_rate_details.exchange_rate_id = finance.exchange_rates.exchange_rate_id
    WHERE finance.exchange_rates.office_id=$1
    AND foreign_currency_code=$2;

    IF(_unit = 0) THEN
        RETURN 0;
    END IF;
    
    RETURN _exchange_rate/_unit;    
END
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS finance.get_exchange_rate(office_id integer, source_currency_code national character varying(12), destination_currency_code national character varying(12));

CREATE FUNCTION finance.get_exchange_rate(office_id integer, source_currency_code national character varying(12), destination_currency_code national character varying(12))
RETURNS decimal_strict2
AS
$$
    DECLARE _unit integer_strict2 = 0;
    DECLARE _exchange_rate decimal_strict2=0;
    DECLARE _from_source_currency decimal_strict2=0;
    DECLARE _from_destination_currency decimal_strict2=0;
BEGIN
    IF($2 = $3) THEN
        RETURN 1;
    END IF;


    _from_source_currency := finance.get_exchange_rate($1, $2);
    _from_destination_currency := finance.get_exchange_rate($1, $3);
        
    RETURN _from_source_currency / _from_destination_currency ; 
END
$$
LANGUAGE plpgsql;

--SELECT * FROM  finance.get_exchange_rate(1, 'USD')
