IF OBJECT_ID('finance.get_journal_view') IS NOT NULL
DROP FUNCTION finance.get_journal_view;

GO

CREATE FUNCTION finance.get_journal_view
(
    @user_id                        integer,
    @office_id                      integer,
    @from                           date,
    @to                             date,
    @tran_id                        bigint,
    @tran_code                      national character varying(50),
    @book                           national character varying(50),
    @reference_number               national character varying(50),
    @amount				            numeric(30, 6),
    @statement_reference            national character varying(2000),
    @posted_by                      national character varying(50),
    @office                         national character varying(50),
    @status                         national character varying(12),
    @verified_by                    national character varying(50),
    @reason                         national character varying(128)
)
RETURNS @result TABLE
(
    transaction_master_id           bigint,
    transaction_code                national character varying(50),
    book                            national character varying(50),
    value_date                      date,
    book_date                          date,
    reference_number                national character varying(24),
    amount				            numeric(30, 6),
	statement_reference             national character varying(2000),
    posted_by                       national character varying(1000),
    office national character varying(1000),
    status                          national character varying(1000),
    verified_by                     national character varying(1000),
    verified_on                     DATETIMEOFFSET,
    reason                          national character varying(128),
    transaction_ts                  DATETIMEOFFSET
)
AS

BEGIN
    WITH office_cte(office_id) AS 
    (
        SELECT @office_id
        UNION ALL
        SELECT
            c.office_id
        FROM 
        office_cte AS p, 
        core.offices AS c 
        WHERE 
        parent_office_id = p.office_id
    )

    INSERT INTO @result
    SELECT 
        finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code,
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number,
		SUM
		(
			CASE WHEN finance.transaction_details.tran_type = 'Cr' THEN 1 ELSE 0 END 
				* 
			finance.transaction_details.amount_in_local_currency
		), 
        finance.transaction_master.statement_reference,
        account.get_name_by_user_id(finance.transaction_master.user_id) as posted_by,
        core.get_office_name_by_office_id(finance.transaction_master.office_id) as office,
        finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id) as status,
        account.get_name_by_user_id(finance.transaction_master.verified_by_user_id) as verified_by,
        finance.transaction_master.last_verified_on AS verified_on,
        finance.transaction_master.verification_reason AS reason,    
        finance.transaction_master.transaction_ts
    FROM finance.transaction_master
	INNER JOIN finance.transaction_details
	ON finance.transaction_details.transaction_master_id = finance.transaction_master.transaction_master_id
    WHERE 1 = 1
    AND finance.transaction_master.value_date BETWEEN @from AND @to
    AND finance.transaction_master.office_id IN (SELECT office_id FROM office_cte)
    AND (@tran_id = 0 OR @tran_id  = finance.transaction_master.transaction_master_id)
    AND LOWER(finance.transaction_master.transaction_code) LIKE '%' + LOWER(@tran_code) + '%' 
    AND LOWER(finance.transaction_master.book) LIKE '%' + LOWER(@book) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.reference_number), '') LIKE '%' + LOWER(@reference_number) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.statement_reference), '') LIKE '%' + LOWER(@statement_reference) + '%' 
    AND COALESCE(LOWER(finance.transaction_master.verification_reason), '') LIKE '%' + LOWER(@reason) + '%' 
    AND LOWER(account.get_name_by_user_id(finance.transaction_master.user_id)) LIKE '%' + LOWER(@posted_by) + '%' 
    AND LOWER(core.get_office_name_by_office_id(finance.transaction_master.office_id)) LIKE '%' + LOWER(@office) + '%' 
    AND COALESCE(LOWER(finance.get_verification_status_name_by_verification_status_id(finance.transaction_master.verification_status_id)), '') LIKE '%' + LOWER(@status) + '%' 
    AND COALESCE(LOWER(account.get_name_by_user_id(finance.transaction_master.verified_by_user_id)), '') LIKE '%' + LOWER(@verified_by) + '%'    
    AND finance.transaction_master.deleted = 0
	GROUP BY 
		finance.transaction_master.transaction_master_id, 
        finance.transaction_master.transaction_code,
        finance.transaction_master.book,
        finance.transaction_master.value_date,
        finance.transaction_master.book_date,
        finance.transaction_master.reference_number,
		finance.transaction_master.statement_reference,
		finance.transaction_master.last_verified_on,
        finance.transaction_master.verification_reason,    
        finance.transaction_master.transaction_ts,
		finance.transaction_master.verified_by_user_id,
		finance.transaction_master.user_id,
		finance.transaction_master.office_id,
		finance.transaction_master.verification_status_id
	HAVING SUM
		(
			CASE WHEN finance.transaction_details.tran_type = 'Cr' THEN 1 ELSE 0 END 
				* 
			finance.transaction_details.amount_in_local_currency
		) = @amount
		OR @amount = 0
    ORDER BY value_date ASC, verification_status_id DESC;

    RETURN;
END;

GO



--SELECT * FROM finance.get_journal_view(2,1,'1-1-2000','1-1-2020',0,'', 'Inventory Transfer', '', 0, '','', '','','', '');

