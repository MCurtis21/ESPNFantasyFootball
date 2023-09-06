Select *
From SQLPractice.dbo.ADPComp23
--Order BY Underdog
-------------------------------------------------------------------------------------------------------------
--1 Deleting Useless Columns

ALTER TABLE SQLPractice.dbo.ADPComp23
Drop Column CBS, FFPC, BB10s,Y_

ALTER TABLE SQLPractice.dbo.ADPComp23
Drop Column NFL, "10-Team"

--How do I delete a column with a number in it?
--Place in double quotes
-------------------------------------------------------------------------------------------------------------
--2 Separating the position column into two columns

Select 
PARSENAME(Replace(Position, '-', '.'),2)
, PARSENAME(Replace(Position, '-', '.'),1)
From SQLPractice.dbo.ADPComp23

ALTER TABLE SQLPractice.dbo.ADPComp23
Add PosNewer Nvarchar(255);

Update SQLPractice.dbo.ADPComp23
SET PosNewer = PARSENAME(Replace(Position, '-', '.'),2)

ALTER TABLE SQLPractice.dbo.ADPComp23
Add PositionRank int;

Update SQLPractice.dbo.ADPComp23
SET PositionRank = PARSENAME(Replace(Position, '-', '.'),1)

--ALTER TABLE SQLPractice.dbo.ADPComp23
--Drop Column PositionNew, PositionNewer, PosNewer, PositionRank

-------------------------------------------------------------------------------------------------------------
--3 Finding the ADP Difference between Underdog and ESPN
--Positive values mean ESPN is UNDERvaluing the player
--Negative values mean ESPN is OVERvaluing the player
--All assuming that Underdog's rankings are sharper (assumption made based upon Fantasy Football Media + News + Community)



Select Player, Underdog, ESPN, (ESPN-Underdog) as ADPversus
From SQLPractice.dbo.ADPComp23
WHERE Underdog < 50
Order BY 4 desc

ALTER TABLE SQLPractice.dbo.ADPComp23
Add ADPDiff int;

Update SQLPractice.dbo.ADPComp23
SET ADPDiff = (ESPN-Underdog)

--This statement below can be used to view players in a certain position group that are being undervalued on the ESPN platform
Select *
From SQLPractice.dbo.ADPComp23
WHERE Underdog < 100
--AND Underdog < 100
AND PosNewer = 'WR'
and ADPDiff > 0
Order BY ADPDiff desc

-------------------------------------------------------------------------------------------------------------
--4 Renaming ADP column to avoid confusion

--Update SQLPractice.dbo.ADPComp23
--RENAME COlumn ADP to ADPavg;
--didn't work in this syntax of SQL

EXEC sp_rename 'dbo.ADPComp23.ADP', 'ADPavg', 'COLUMN';

Select *
From SQLPractice.dbo.ADPComp23
WHERE Underdog < 200
and ADPDiff is not null
Order By Underdog
--Order BY ADPDiff desc

-------------------------------------------------------------------------------------------------------------
--5 Adding a round column using a case statement 

Select *
From SQLPractice.dbo.ADPComp23
WHERE ESPN < 200
Order BY ESPN 


Select ADPavg, Player, ESPN,
CASE 
	WHEN ESPN < 13 THEN '1'
	WHEN ESPN between 13 and 24 THEN '2'
	WHEN ESPN between 25 and 36 THEN '3'
	WHEN ESPN between 37 and 48 THEN '4'
	WHEN ESPN between 49 and 60 THEN '5'
	WHEN ESPN between 61 and 72 THEN '6'
	WHEN ESPN between 73 and 84 THEN '7'
	WHEN ESPN between 85 and 96 THEN '8'
	WHEN ESPN between 97 and 108 THEN '9'
	WHEN ESPN between 109 and 120 THEN '10'
	WHEN ESPN between 121 and 132 THEN '11'
	WHEN ESPN between 133 and 144 THEN '12'
	WHEN ESPN between 145 and 156 THEN '13'
	WHEN ESPN between 157 and 168 THEN '14'
	WHEN ESPN between 169 and 180 THEN '15'
	WHEN ESPN between 181 and 192 THEN '16'
	ELSE 'Undrafted'
END AS ESPNround
From SQLPractice.dbo.ADPComp23
WHERE ESPN < 200
ORDER BY ESPN

ALTER TABLE SQLPractice.dbo.ADPComp23
Add ESPNRound int;

Update SQLPractice.dbo.ADPComp23
SET ESPNRound = 
(CASE
	WHEN ESPN < 13 THEN '1'
	WHEN ESPN between 13 and 24 THEN '2'
	WHEN ESPN between 25 and 36 THEN '3'
	WHEN ESPN between 37 and 48 THEN '4'
	WHEN ESPN between 49 and 60 THEN '5'
	WHEN ESPN between 61 and 72 THEN '6'
	WHEN ESPN between 73 and 84 THEN '7'
	WHEN ESPN between 85 and 96 THEN '8'
	WHEN ESPN between 97 and 108 THEN '9'
	WHEN ESPN between 109 and 120 THEN '10'
	WHEN ESPN between 121 and 132 THEN '11'
	WHEN ESPN between 133 and 144 THEN '12'
	WHEN ESPN between 145 and 156 THEN '13'
	WHEN ESPN between 157 and 168 THEN '14'
	WHEN ESPN between 169 and 180 THEN '15'
	WHEN ESPN between 181 and 192 THEN '16'
	ELSE '17'
END);

--Updating Table -  If a player has a null value for the ESPN ADP, I am assigning them an ADP value of 201. This way, we can still
--see what the difference is between Underdog's ADP and this placeholder ESPN ADP I'm assigning. 

Update SQLPractice.dbo.ADPComp23
SET ESPN = '201'
where ESPN is null

--Similar Update - If a player has a null value for the Underdog ADP, I am assigning them an ADP value of 300. This way, we can still
--see what the difference is between this placeholder Underdog ADP and the ESPN ADP. 

Update SQLPractice.dbo.ADPComp23
SET Underdog = '300'
where Underdog is null

--Check to make sure we have solved the issue of having null values 

Select *
From SQLPractice.dbo.ADPComp23
--WHERE Underdog < 200
--and ADPDiff is null
Order By ESPN

--This table is especially useful for us given the fact that we need to bring it into Excel and then into Tableau
--because of our restrictions set by Tableau Public