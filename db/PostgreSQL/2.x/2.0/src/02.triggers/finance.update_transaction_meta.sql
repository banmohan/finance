DROP FUNCTION IF EXISTS finance.update_transaction_meta() CASCADE;

CREATE FUNCTION finance.update_transaction_meta()
RETURNS TRIGGER
AS
$$
    DECLARE _transaction_master_id          bigint;
    DECLARE _current_transaction_counter    integer;
    DECLARE _current_transaction_code       national character varying(50);
    DECLARE _value_date                     date;
    DECLARE _office_id                      integer;
    DECLARE _user_id                        integer;
    DECLARE _login_id                       bigint;
BEGIN
    _transaction_master_id                  := NEW.transaction_master_id;
    _current_transaction_counter            := NEW.transaction_counter;
    _current_transaction_code               := NEW.transaction_code;
    _value_date                             := NEW.value_date;
    _office_id                              := NEW.office_id;
    _user_id                                := NEW.user_id;
    _login_id                               := NEW.login_id;

    IF(COALESCE(_current_transaction_code, '') = '') THEN
        UPDATE finance.transaction_master
        SET transaction_code = finance.get_transaction_code(_value_date, _office_id, _user_id, _login_id)
        WHERE transaction_master_id = _transaction_master_id;
    END IF;

    IF(COALESCE(_current_transaction_counter, 0) = 0) THEN
        UPDATE finance.transaction_master
        SET transaction_counter = finance.get_new_transaction_counter(_value_date)
        WHERE transaction_master_id = _transaction_master_id;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql;

CREATE TRIGGER update_transaction_meta
AFTER INSERT
ON finance.transaction_master
FOR EACH ROW EXECUTE PROCEDURE finance.update_transaction_meta();
