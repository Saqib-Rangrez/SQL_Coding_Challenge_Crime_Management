--CODING CHALLENGE - CRIME MANAGEMENT


--Create database named CrimeManagement

CREATE DATABASE CrimeManagement;

USE CrimeManagement;


--Create all the required tables

CREATE TABLE Crime (
	CrimeID INT PRIMARY KEY,
	IncidentType VARCHAR(255),
	IncidentDate DATE,
	Location VARCHAR(255),
	Description TEXT,
	Status VARCHAR(20)
);

CREATE TABLE Victim (
	VictimID INT PRIMARY KEY,
	CrimeID INT,
	Name VARCHAR(255),
	ContactInfo VARCHAR(255),
	Injuries VARCHAR(255),
	FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Suspect (
	SuspectID INT PRIMARY KEY,
	CrimeID INT,
	Name VARCHAR(255),
	Description TEXT,
	CriminalHistory TEXT,
	FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);


--Insert sample data into tables

INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status) VALUES
(1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
(2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
(3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries) VALUES
(1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
(2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');

INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory) VALUES
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
(2, 2, 'Unknown', 'Investigation ongoing', NULL),
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');


--------------------------------------------------------------------------------------------------------------------------------

--Tasks
-- 1. Select all open incidents.	

SELECT * FROM Crime WHERE Status = 'Open';



-- 2. Find the total number of incidents.

SELECT COUNT(*) AS TotalIncidents FROM Crime;



-- 3. List all unique incident types.

SELECT DISTINCT IncidentType FROM Crime;



-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.

SELECT * FROM Crime WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';



-- 5. 
-- As there is no Age column we need to add and insert data for it as it is requiredd in further queries

ALTER TABLE Victim ADD Age INT;

UPDATE Victim
SET Age = 
    CASE 
        WHEN VictimID = 1 THEN 35
        WHEN VictimID = 2 THEN 45
        WHEN VictimID = 3 THEN 55
    END
WHERE VictimID IN (1, 2, 3);

ALTER TABLE Suspect ADD Age INT;

UPDATE Suspect
SET Age = 
    CASE 
        WHEN SuspectID = 1 THEN 30
        WHEN SuspectID = 2 THEN 40
        WHEN SuspectID = 3 THEN 50
    END
WHERE SuspectID IN (1, 2, 3);
--Execute the above alter and update command before proceeding ahead


--5. List persons involved in incidents in descending order of age.
SELECT Name, Age FROM Victim
UNION
SELECT Name, Age FROM Suspect
ORDER BY Age DESC;



-- 6. Find the average age of persons involved in incidents.
SELECT AVG(Age) AS AverageAge FROM (
    SELECT Age FROM Victim
    UNION
    SELECT Age FROM Suspect
) AS AllAges;



-- 7. List incident types and their counts, only for open cases.

SELECT IncidentType, COUNT(*) AS IncidentCount FROM Crime WHERE Status = 'Open' GROUP BY IncidentType;



-- 8. Find persons with names containing 'Doe'.

SELECT Name FROM Victim WHERE Name LIKE '%Doe%'
UNION
SELECT Name FROM Suspect WHERE Name LIKE '%Doe%';



-- 9. Retrieve the names of persons involved in open cases and closed cases.

SELECT Name FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Open')
UNION
SELECT Name FROM Victim WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed')
UNION
SELECT Name FROM Suspect WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE Status = 'Closed');



-- 10. List incident types where there are persons aged 30 or 35 involved.

SELECT DISTINCT C.IncidentType from Crime C
LEFT JOIN Victim V on V.CrimeID=C.CrimeID
where V.age=30 or V.age=35 ;  



-- 11. Find persons involved in incidents of the same type as 'Robbery'.
SELECT Name
FROM Victim
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery')
UNION
SELECT Name
FROM Suspect
WHERE CrimeID IN (SELECT CrimeID FROM Crime WHERE IncidentType = 'Robbery');



-- 12. List incident types with more than one open case.  (No data as there are no more than 1 open cases)
SELECT IncidentType, COUNT(*) AS OpenCases
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType
HAVING COUNT(*) > 1;



-- 13. List all incidents with suspects whose names also appear as victims in other incidents. (No data as there are no such cases)

SELECT C.*, V.Name AS VictimName, S.Name AS SuspectName
FROM Crime C
JOIN Victim V ON C.CrimeID = V.CrimeID
JOIN Suspect S ON C.CrimeID = S.CrimeID AND V.Name = S.Name;



-- 14. Retrieve all incidents along with victim and suspect details.

SELECT C.*, V.Name AS VictimName, V.ContactInfo, V.Injuries, S.Name AS SuspectName, S.Description AS SuspectDescription, S.CriminalHistory
FROM Crime C
LEFT JOIN Victim V ON C.CrimeID = V.CrimeID
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID;



-- 15. Find incidents where the suspect is older than any victim. (No data as thera are no such cases)

SELECT C.*
FROM Crime C
JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE S.Age > ANY (SELECT Age FROM Victim WHERE CrimeID = C.CrimeID);



-- 16. Find suspects involved in multiple incidents: (No data as there are no such cases)

SELECT SuspectID, Name, COUNT(CrimeID) AS IncidentCount
FROM Suspect
GROUP BY SuspectID, Name
HAVING COUNT(CrimeID) > 1;



-- 17. List incidents with no suspects involved. No data as ther are No such cases

SELECT C.*
FROM Crime C
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID
WHERE S.Name = 'Unknown';



-- 18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery' 

  SELECT * FROM Crime WHERE IncidentType = 'Homicide' OR IncidentType = 'Robbery';


-- 19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none.

SELECT C.*, ISNULL(S.Name, 'No Suspect') AS SuspectName
FROM Crime C
LEFT JOIN Suspect S ON C.CrimeID = S.CrimeID AND S.Name <> 'Unknown';



-- 20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault'

SELECT S.* FROM Suspect S
JOIN Crime C ON S.CrimeID = C.CrimeID
WHERE C.IncidentType IN ('Robbery', 'Assault');