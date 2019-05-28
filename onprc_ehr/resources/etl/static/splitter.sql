/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
If Exists (SELECT * FROM sysobjects WHERE id = object_id('fn_splitter') and type = 'TF')
      DROP FUNCTION fn_splitter
GO
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