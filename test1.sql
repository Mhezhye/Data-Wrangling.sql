--Veterinary clinic Data wrangling

Skills used: Joins, Creating Views, String functions, CAST function, Aggregate function and User Defined Functions

--STEP 1--Create a view containing all information in the Client Table
CREATE VIEW CLIENT AS
SELECT DISTINCT c.ID AS 'Client External ID', ct.Name+' '+ c.FirstName AS FirstName, c.LastName, dbo.getnumeric(c.PostalLine4) AS Phone,
dbo.fn_getAlphabet(c.PostalLine4) AS City
FROM dbo.Customer c
Inner join dbo.CustomerTitle ct ON ct.ID=c.TitleID
GO

--STEP 2 Concatenate Internal Notes for customers
Select c.ID AS 'Client_External_ID' , ctm.Description AS Note, cs.Description AS Note2,c.Comment AS Note3, ch.Comment AS Note4, 
cp.Description AS Note5
INTO CMAIN
FROM dbo.Customer c
Left join dbo.CustomerHistory ch ON ch.CustomerID = c.ID
Left Join dbo.CustomerStatus CS ON cs.ID = c.StatusID
Left Join dbo.CustomerTerms ctm ON ctm.ID=c.TermsID
Left join dbo.CustomerProfile cp ON cp.ID= c.ProfileID
SELECT CONCAT(Note,Note2,Note3,Note4,Note5) AS INTERNAL_NOTE , Client_External_ID  INTO CMAIN2 FROM CMAIN

--STEP 3 Create a view containing all information in the Client_Optional Table
CREATE VIEW CLIENT_Optional AS
SELECT  c.ID AS 'Personal ID Number' , ' ' AS Email, c.PostalLine4 AS Address, ' ' AS Birthdate, cm.Internal_Note
FROM dbo.Customer c
Left join dbo.CustomerHistory ch ON ch.CustomerID = c.ID
Left Join dbo.CustomerStatus CS ON cs.ID = c.StatusID
Left Join dbo.CustomerTerms ctm ON ctm.ID=c.TermsID
Left join dbo.Patient p ON p.CustomerID= c.ID
Left join dbo.CMAIN2 cm ON cm.Client_External_ID = c.ID

GO

--STEP 4 Create a view containing all information in the Pet Table
CREATE VIEW PET AS
SELECT p.ID AS 'Pet External ID', p.Name, b.Name AS Breed, s.Name AS Species, p.PatientGenderID AS SEX, 
p.Sterile AS 'Reproductive Status', CAST(p.DOB AS date) AS Birthdate,c.ID
FROM dbo.Patient p
left join dbo.Breed b ON b.ID= p.BreedID
left join dbo.Specie s ON s.ID= b.SpecieID
left Join dbo.Customer c ON c.ID= p.CustomerID
GO

--STEP 5 Concatenate the internal notes for pets
Select p.ID, pn.ID AS UserID,dbo.RTF2TXT(pn.Note) AS Note,p.comment AS Note2,pcn.Note AS Note3, w.comment AS Note4,
b.Description + '' + s.Description AS 'Descript'
INTO MAIN
from dbo.PatientNote pn
left JOIN dbo.Patient p ON pn.PatientID=p.ID
Left join dbo.Breed b ON b.ID=p.BreedID
Left join dbo.Specie s ON s.ID= b.SpecieID
left JOIN dbo.Weight w ON p.ID=w.PatientID
left join dbo.PatientCriticalNote pcn ON pcn.PatientID=w.PatientID 
SELECT CONCAT(Note,Note2,Note3,Note4) AS 'INTERNAL_NOTE' , ID, UserID, Descript  INTO MAIN2 FROM MAIN
SELECT ID, STRING_AGG(ISNULL(UserID, ' '), ',' )AS UserID, STRING_AGG(ISNULL(Descript, ' '), ',' )AS 'Description',
STRING_AGG(ISNULL(INTERNAL_NOTE, ' '), ',' )AS INTERNAL_NOTE INTO MAIN3 FROM MAIN2
GROUP BY ID


--STEP 6 Create a view containing all information in the Pet_Optional Table
CREATE VIEW PET_Optional AS
SELECT DISTINCT p.ID AS 'Internal Number', p.ColourMarkings AS Color, ' ' AS 'Distinctive Marks', ' ' as Insurance#, ' ' as 'Microchip ID',
p.Photo AS 'Passport Series',  m.UserID AS 'Health Card Number',  ' ' AS Allergies, 
m.Description AS 'Description' ,
p.PatientStatusID AS Active, m. [INTERNAL_NOTE] ,CAST(p.DOD as date) AS 'Date of Decease', ' ' AS 'Reason of Decease'
FROM dbo.Patient p
Left join dbo.Breed b ON b.ID=p.BreedID
Left join dbo.Specie s ON s.ID= b.SpecieID
Left join dbo.PatientNote pn ON pn.PatientID = p.ID
Left join dbo.MAIN3 m ON m.ID = p.ID
GO


--STEP 7 Use Left join to concatenate all views into the required final format
SELECT DISTINCT * FROM CLIENT
LEFT JOIN CLIENT_Optional
ON CLIENT.[Client External ID]= CLIENT_Optional.[Personal ID Number]
LEFT JOIN  PET
ON PET.ID = CLIENT.[Client External ID]
LEFT JOIN PET_Optional
ON PET.[Pet External ID] =PET_Optional.[Internal Number]
