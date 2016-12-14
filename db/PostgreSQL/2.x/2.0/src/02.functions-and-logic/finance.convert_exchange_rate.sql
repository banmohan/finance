DROP FUNCTION IF EXISTS finance.convert_exchange_rate(office_id integer, source_currency_code national character varying(12), destination_currency_code national character varying(12));

CREATE FUNCTION finance.convert_exchange_rate(office_id integer, source_currency_code national character varying(12), destination_currency_code national character varying(12))
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

--SELECT * FROM  finance.convert_exchange_rate(1, 'USD', 'NPR');
