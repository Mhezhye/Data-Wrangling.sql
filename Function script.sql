--Function one---Create a function to extract numbers from a column
Create function dbo.getnumeric
(
@strAlphaNumeric VARCHAR(200)
)
RETURNS VARCHAR(200)
AS
BEGIN
DECLARE @intAlpha INT
SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
BEGIN
WHILE @intAlpha > 0
BEGIN
SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '')
SET @intAlpha= PATINDEX('%[^0-9]%', @strAlphaNumeric)
END
END
RETURN ISNULL(@strAlphaNumeric, 0)
END
GO

--Function 2--Create a function to extract letters from a column
Create function dbo.fn_getAlphabet
(
@input VARCHAR(50)
)
RETURNS VARCHAR (50)
AS
BEGIN
WHILE PATINDEX('%[^a-z]%', @input) > 0
SET @input=STUFF(@input, PATINDEX('%[^a-z]%',@input), 1,'')
RETURN @input
END


--Function 3-- Create a function to remove rtftags and extract text.
If exists (Select * from sys.objects where object_id = OBJECT_ID(N'[dbo].[RTF2TXT]') AND type in (N'FN', N'IF', N'FS', N'FT'))---RTF2TXT
DROP FUNCTION [dbo].RTF2TXT
GO

CREATE FUNCTION RTF2TXT
(@In VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS 
BEGIN
If isnull(@In, '')='' return ''
If @In not like '{\rtf%' return @In
Declare @Len int
Declare @Loc int= 1
Declare @Char char(1) = ''
Declare @PrevChar char(1) = ''
Declare @NextChar char(1) = ''
Declare @InMarkup int = 0
Declare @InBrackets int = -1
Declare @Out varchar(max) = ''

Set @Len = len(@In)
While @Loc < @Len begin
Set @PrevChar = @Char
Set @Char = SUBSTRING(@In, @Loc, 1)
If @Loc < @Len set @NextChar = SUBSTRING(@In, @Loc + 1, 1) else set @NextChar =''
Set @Loc = @Loc + 1
If @Char = '{' and @PrevChar != '\' begin
Set @InBrackets = @InBrackets + 1
continue

End 
If @Char = '}' and @PrevChar != '\' begin
Set @InBrackets = @InBrackets -1
Continue

End
If @Char = '\' and @PrevChar != '\' and @NextChar not in ('\','{', '}', '~', '-', '_') begin
Set @InMarkup = 1 
continue

End
If @Char =' ' or @Char = char(13) begin
Set @InMarkup = 0

End 
If @InMarkup > 0 or @InBrackets > 0 continue 
Set @Out = @Out + @Char
End

Set @Out = replace(@Out, '\\', '\')
Set @Out = replace(@Out, '\{', '{')
Set @Out = replace(@Out, '\}', '}')
Set @Out = replace(@Out, '\~', ' ')
Set @Out = replace(@Out, '\-', '-')
Set @Out = replace(@Out, '\_', '_')

WHILE ASCII(@Out) < 33
BEGIN
set @Out = substring(@Out, 2,len(@Out))
END

set @Out= reverse(@Out)
WHILE ASCII (@Out) < 33
BEGIN
set @Out = substring(@Out, 2, len(@Out))
END

set @Out = reverse(@Out)

RETURN LTRIM(RTRIM(@Out))
END
