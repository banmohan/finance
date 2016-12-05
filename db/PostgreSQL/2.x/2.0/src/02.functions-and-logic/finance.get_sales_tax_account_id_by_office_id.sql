DROP FUNCTION IF EXISTS finance.get_sales_tax_account_id_by_office_id(_office_id integer);

CREATE FUNCTION finance.get_sales_tax_account_id_by_office_id(_office_id integer)
RETURNS integer
AS
$$
BEGIN
    RETURN finance.tax_setups.sales_tax_account_id
    FROM finance.tax_setups
    WHERE NOT finance.tax_setups.deleted
    AND finance.tax_setups.office_id = _office_id;
END
$$
LANGUAGE plpgsql;