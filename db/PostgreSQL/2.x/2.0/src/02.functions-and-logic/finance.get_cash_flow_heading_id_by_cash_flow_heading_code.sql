DROP FUNCTION IF EXISTS finance.get_cash_flow_heading_id_by_cash_flow_heading_code(_cash_flow_heading_code national character varying(12));

CREATE FUNCTION finance.get_cash_flow_heading_id_by_cash_flow_heading_code(_cash_flow_heading_code national character varying(12))
RETURNS integer
STABLE
AS
$$
BEGIN
    RETURN
        cash_flow_heading_id
    FROM
        finance.cash_flow_headings
    WHERE
        cash_flow_heading_code = $1;
END
$$
LANGUAGE plpgsql;
