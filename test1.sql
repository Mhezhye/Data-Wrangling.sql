--STEP 1
CREATE VIEW CLIENT AS
SELECT DISTINCT c.ID AS 'Client External ID', ct.Name+' '+ c.FirstName AS FirstName, c.LastName, dbo.getnumeric(c.PostalLine4) AS Phone,
dbo.fn_getAlphabet(c.PostalLine4) AS City
FROM dbo.Customer c
Inner join dbo.CustomerTitle ct
ON ct.ID=c.TitleID
GO

--STEP 2
CREATE VIEW CLIENT_Optional AS
SELECT  ' ' AS Email, c.PostalLine4 AS Address, ' ' AS Birthdate, ctm.Description + ' ' + cs.Description AS 'Internal Notes',
c.ID AS 'Personal ID Number'
FROM dbo.Customer c
Inner join dbo.CustomerHistory ch
ON ch.CustomerID = c.ID
Inner Join dbo.CustomerStatus CS 
ON cs.ID = c.StatusID
Inner Join dbo.CustomerTerms ctm
ON ctm.ID=c.TermsID
Inner join dbo.Patient p
on p.CustomerID= c.ID
GO
--STEP 3
CREATE VIEW PET AS
SELECT p.ID AS 'Pet External ID', p.Name, b.Name AS Breed, s.Name AS Species, p.PatientGenderID AS SEX, 
p.Sterile AS 'Reproductive Status', CAST(p.DOB AS date) AS Birthdate,c.ID
FROM dbo.Patient p
Inner join dbo.Breed b ON b.ID= p.BreedID
Inner join dbo.Specie s ON s.ID= b.SpecieID
Inner Join dbo.Customer c ON c.ID= p.CustomerID
GO

--STEP 4
CREATE VIEW PET_Optional AS
SELECT DISTINCT pn.ID AS 'Health Card Number', p.ColourMarkings AS Color, ' ' AS 'Distinctive Marks', ' ' as Insurance#, ' ' as 'Microchip ID',
p.Photo AS 'Passport Series', p.ID AS 'Internal Number', ' ' AS Allergies, 
b.Description + '' + s.Description AS 'Description' , p.PatientStatusID AS Active, dbo.RTF2TXT(pn.Note) + ' ' + p.Comment  AS 'Internal Notes',
CAST(p.DOD as date) AS 'Date of Decease', ' ' AS 'Reason of Decease'
FROM dbo.Patient p
Inner join dbo.Breed b ON b.ID=p.BreedID
Inner join dbo.Specie s ON s.ID= b.SpecieID
Inner join dbo.PatientNote pn ON pn.PatientID = p.ID
GO

--STEP 5
SELECT DISTINCT * FROM CLIENT
LEFT JOIN CLIENT_Optional
ON CLIENT.[Client External ID]= CLIENT_Optional.[Personal ID Number]
LEFT JOIN  PET
ON PET.ID = CLIENT.[Client External ID]
LEFT JOIN PET_Optional
ON PET.[Pet External ID] =PET_Optional.[Internal Number]

