CREATE FUNCTION dbo.fn_splitter(@text nvarchar(max), @separator nvarchar(100))
RETURNS @result TABLE (i int, value nvarchar(max))
AS
BEGIN
    DECLARE @i int
    DECLARE @offset int
    SET @i = 0

    WHILE @text IS NOT NULL
    BEGIN
        SET @i = @i + 1
        SET @offset = charindex(@separator, @text)
        INSERT @result SELECT @i, CASE WHEN @offset > 0 THEN LEFT(@text, @offset - 1) ELSE @text END
        SET @text = CASE WHEN @offset > 0 THEN SUBSTRING(@text, @offset + LEN(@separator), LEN(@text)) END
    END
    RETURN
END