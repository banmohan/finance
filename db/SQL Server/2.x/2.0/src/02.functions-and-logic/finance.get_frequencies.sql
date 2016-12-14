IF OBJECT_ID('finance.get_frequencies') IS NOT NULL
DROP FUNCTION finance.get_frequencies;

GO

CREATE FUNCTION  finance.get_frequencies(@frequency_id integer)
RETURNS @t TABLE
(
    frequency_id    integer
)
AS
BEGIN
    IF(@frequency_id = 2)
    BEGIN
        --End of month
        --End of quarter is also end of third/ninth month
        --End of half is also end of sixth month
        --End of year is also end of twelfth month
        INSERT INTO @t
        SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 3)
    BEGIN

        --End of quarter
        --End of half is the second end of quarter
        --End of year is the fourth/last end of quarter
        INSERT INTO @t
        SELECT 3 UNION SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 4)
    BEGIN
        --End of half
        --End of year is the second end of half
        INSERT INTO @t
        SELECT 4 UNION SELECT 5;
    END
    ELSE IF(@frequency_id = 5)
    BEGIN
        --End of year
        INSERT INTO @t
        SELECT 5;
    END;

    RETURN;
END;




GO
