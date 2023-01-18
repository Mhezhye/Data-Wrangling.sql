---Automate OLE Automation Procedures
Exec sp_configure 'show advanced options', 1
Go
reconfigure
Go
exec sp_configure 'Ole Automation Procedures', 1--Enable
--exec sp_configure 'Ole Automation Procedures', 0
Go
reconfigure
Go
exec sp_configure 'show advanced options', 0
Go
reconfigure
Go


if (Object_id('dbo.fns') IS NOT NULL)
Begin 
Drop Function dbo.fns
End
Go
Create Function dbo.fns
(
@string varchar(8000)
)
returns varchar(8000)
AS
BEGIN
declare @text varchar(8000),
@PenDown Char(1),
@Char Char(1),
@len int,
@count int
select @count = 0,
@len = 0,
@text = ''

select @string = '>' + @string +'<'
select @len = len(@string)
while (@count <=@len)
begin
select @char = substring(@string,@count,1)

if (@char = '>')
select @PenDown= 'N'
else
if (@PenDown = 'Y')
select @text = @text + @char

select @count = @count + 1
end

RETURN @text
END
GO


using system.data.sqltypes;
using itenso.rtf.converter.Text;
using itenso.rtf.support;

public partial class StoredProcedures
{
[Microsoft.Sqlserer.Server.sqlfunction]
public static sqlstring RtfToPlainText(SqlString text)
{	
if (text.Value.StartWith(@'{\rtf'))
{
RtfTextConverter textConverter = new RtfTextConverter();
RtfInterpreterTool.Interpret(text.Value, textConverter);
return textConverter.PlainText;
}
else
return text;
}
}

Drop function dbo.getnumeric
Create function dbo.getnumeric---to get numbers only
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

Drop Function dbo.fn_getAlphabet
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