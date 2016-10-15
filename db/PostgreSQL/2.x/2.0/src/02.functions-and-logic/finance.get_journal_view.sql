DROP FUNCTION IF EXISTS finance.get_journal_view
(
    _user_id                        integer,
    _office_id                      integer,
    _from                           date,
    _to                             date,
    _tran_id                        bigint,
    _tran_code                      national character varying(50),
    _book                           national character varying(50),
    _reference_number               national character varying(50),
    _statement_reference            national character varying(50),
    _posted_by                      national character varying(50),
    _office                         national character varying(50),
    _status                         national character varying(12),
    _verified_by                    national character varying(50),
    _reason                         national character varying(128)
);

CREATE FUNCTION finance.get_journal_view
(
    _user_id                        integer,
    _office_id                      integer,
    _from                           date,
    _to                             date,
    _tran_id                        bigint,
    _tran_code                      national character varying(50),
    _book                           national character varying(50),
    _reference_number               national character varying(50),
    _statement_reference            national character varying(50),
    _posted_by                      national character varying(50),
    _office                         national character varying(50),
    _status                         national character varying(12),
    _verified_by                    national character varying(50),
    _reason                         national character varying(128)
)
RETURNS TABLE
(
    transaction_master_id           bigint,
    transaction_code                national character varying(50),
    book                            national character varying(50),
    value_date                      date,
    book_date                      	date,
    reference_number                national character varying(24),
    statement_reference             text,
    posted_by                       text,
    office                          text,
    status                          text,
    verified_by                     text,
    verified_on                     TIMESTAMP WITH TIME ZONE,
    reason                          national character varying(128),
    transaction_ts                  TIMESTAMP WITH TIME ZONE
)
AS
$$
BEGIN
    RETURN QUERY
    WITH RECURSIVE office_cte(office_id) AS 
    (
        SELECT _office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    SELECT 
        finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code,
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number,
        finance.transaction_master.statement_reference,
        account.get_name_by_user_id(finance.transaction_master.user_id) as posted_by,
        core.get_office_name_by_office_id(finance.transaction_master.office_id) as office,
        finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) as status,
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) as verified_by,
        finance.transaction_master.last_verified_on AS verified_on,
        finance.transaction_master.verification_reason AS reason,    
        finance.transaction_master.transaction_ts
    FROM finance.transaction_master
    WHERE 1 = 1
    AND finance.transaction_master.value_date BETWEEN _from AND _to
    AND office_id IN (SELECT office_id FROM office_cte)
    AND (_tran_id = 0 OR _tran_id  = finance.transaction_master.transaction_master_id)
    AND lower(finance.transaction_master.transaction_code) LIKE '%' || lower(_tran_code) || '%' 
    AND lower(finance.transaction_master.book) LIKE '%' || lower(_book) || '%' 
    AND COALESCE(lower(finance.transaction_master.reference_number), '') LIKE '%' || lower(_reference_number) || '%' 
    AND COALESCE(lower(finance.transaction_master.statement_reference), '') LIKE '%' || lower(_statement_reference) || '%' 
    AND COALESCE(lower(finance.transaction_master.verification_reason), '') LIKE '%' || lower(_reason) || '%' 
    AND lower(account.get_name_by_user_id(finance.transaction_master.user_id)) LIKE '%' || lower(_posted_by) || '%' 
    AND lower(core.get_office_name_by_office_id(finance.transaction_master.office_id)) LIKE '%' || lower(_office) || '%' 
    AND COALESCE(lower(finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id)), '') LIKE '%' || lower(_status) || '%' 
    AND COALESCE(lower(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id)), '') LIKE '%' || lower(_verified_by) || '%'    
    ORDER BY value_date ASC, verification_status_id DESC;
END
$$
LANGUAGE plpgsql;


--SELECT * FROM finance.get_journal_view(2,1,'1-1-2000','1-1-2020',0,'', 'Inventory Transfer', '', '','', '','','', '');


