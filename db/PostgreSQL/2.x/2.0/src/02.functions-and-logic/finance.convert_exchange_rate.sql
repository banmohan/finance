DROP FUNCTION IF EXISTS finance.convert_exchange_rate(_office_id integer, _source_currency_code national character varying(12), _destination_currency_code national character varying(12));

CREATE FUNCTION finance.convert_exchange_rate(_office_id integer, _source_currency_code national character varying(12), _destination_currency_code national character varying(12))
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


    _from_source_currency := finance.get_exchange_rate(_office_id, _source_currency_code);
    _from_destination_currency := finance.get_exchange_rate(_office_id, _destination_currency_code);

	IF(_from_destination_currency = 0) THEN
		RETURN NULL;
	END IF;

    RETURN _from_source_currency / _from_destination_currency;
END
$$
LANGUAGE plpgsql;

--SELECT * FROM finance.convert_exchange_rate(1, 'NPR', 'NPR');

