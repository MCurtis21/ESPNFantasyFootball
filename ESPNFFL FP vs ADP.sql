--------------------------------------------------------------------------------------------------------------------------------------------------
--Let's look at the data we have 
Select *
From ESPNFF.dbo.ADPFinal
Order by ADP

Select *
From ESPNFF.dbo.FPTSFinal

--------------------------------------------------------------------------------------------------------------------------------------------------
--Let's join the data using the unique player IDs and the years. 
--Players have the same ID regardless of year, so we cannot miss that part

Select adp.PlayerID, adp.ADP, adp.Year, adp.Name, adp.Position, adp.PositionRank, fpts.Rk, fpts.Team
From ESPNFF.dbo.ADPFinal adp
Join ESPNFF.dbo.FPTSFinal fpts
	on adp.PlayerID = fpts.ID
	and adp.Year = fpts.Year
--where is not null
order by 2, 3


Select *
From ESPNFF.dbo.ADPFinal
Order BY ADP 

--Adding a column for the draft round

Select *,
CASE 
	WHEN ADP < 13 THEN '1'
	WHEN ADP between 13 and 24 THEN '2'
	WHEN ADP between 25 and 36 THEN '3'
	WHEN ADP between 37 and 48 THEN '4'
	WHEN ADP between 49 and 60 THEN '5'
	WHEN ADP between 61 and 72 THEN '6'
	WHEN ADP between 73 and 84 THEN '7'
	WHEN ADP between 85 and 96 THEN '8'
	WHEN ADP between 97 and 108 THEN '9'
	WHEN ADP between 109 and 120 THEN '10'
	WHEN ADP between 121 and 132 THEN '11'
	WHEN ADP between 133 and 144 THEN '12'
	WHEN ADP between 145 and 156 THEN '13'
	WHEN ADP between 157 and 168 THEN '14'
	WHEN ADP between 169 and 180 THEN '15'
	WHEN ADP between 181 and 192 THEN '16'
	ELSE 'Undrafted'
END AS DraftRound
From ESPNFF.dbo.ADPFinal
--WHERE ESPN < 200
ORDER BY ADP

ALTER TABLE ESPNFF.dbo.ADPFinal
Add DraftRound int;

Update ESPNFF.dbo.ADPFinal
SET DraftRound = 
(CASE 
	WHEN ADP < 13 THEN '1'
	WHEN ADP between 13 and 24 THEN '2'
	WHEN ADP between 25 and 36 THEN '3'
	WHEN ADP between 37 and 48 THEN '4'
	WHEN ADP between 49 and 60 THEN '5'
	WHEN ADP between 61 and 72 THEN '6'
	WHEN ADP between 73 and 84 THEN '7'
	WHEN ADP between 85 and 96 THEN '8'
	WHEN ADP between 97 and 108 THEN '9'
	WHEN ADP between 109 and 120 THEN '10'
	WHEN ADP between 121 and 132 THEN '11'
	WHEN ADP between 133 and 144 THEN '12'
	WHEN ADP between 145 and 156 THEN '13'
	WHEN ADP between 157 and 168 THEN '14'
	WHEN ADP between 169 and 180 THEN '15'
	WHEN ADP between 181 and 192 THEN '16'
	ELSE 17
END);

Select adp.PlayerID, adp.ADP, adp.Year, adp.Name, adp.Position, adp.DraftRound, fpts.Rk, fpts.FPTS
From ESPNFF.dbo.ADPFinal adp
Join ESPNFF.dbo.FPTSFinal fpts
	on adp.PlayerID = fpts.ID
	and adp.Year = fpts.Year
--where is not null
order by 6, 3

--------------------------------------------------------------------------------------------------------------------------------------------------
--Cleaning up the data by rounding decimals 

Select FPTS, Round(FPTS, 1) as 'FPTSRounded'
From ESPNFF.dbo.FPTSFinal

ALTER TABLE ESPNFF.dbo.FPTSFinal
Add FPTSRounded int;

Update ESPNFF.dbo.FPTSFinal
Set FPTSRounded = Round(FPTS, 1);

--------------------------------------------------------------------------------------------------------------------------------------------------
--Using a left join so that all the players who were drafted in ESPN leagues can be seen in the data
--The ADPFinal data only has the top 200 players drafted each year,
--The FPTSFinal data only has the top 300 players each year,
--so players who were drafted in the top 200 but did not finish the season in the top 300 were being excluded

Select adp.PlayerID, adp.ADP, adp.Year, adp.Name, adp.Position, adp.DraftRound, fpts.Rk, fpts.FPTSRounded
From ESPNFF.dbo.ADPFinal adp
Left Join ESPNFF.dbo.FPTSFinal fpts
	on adp.PlayerID = fpts.ID
	and adp.Year = fpts.Year
--where is not null
--order by 8  
order by 6, 3


--------------------------------------------------------------------------------------------------------------------------------------------------
--From this data we can see that if a player did not score 100 FPTS in one season, 
--they did not even crack into the top 300 scoring players (Rk) for that season
--Given this, it is fair to assign those players 100 FPTS and Rk 300. 
--In reality, they probably scored less than this and finished worse than this, but these numbers
--will still prove that they were not good enough to be a starter in a Weekly ESPN FFL Lineup
--All Players with Null values in the Left Join are the players that fit the description above
--I'm going to create a Temp Table to do all of this 

Drop Table if exists #FantasyData
--Must include above if any changes are made
Create Table #FantasyData
(
PlayerID numeric, 
ADP numeric, 
Year numeric, 
Name nvarchar(255), 
Position nvarchar(255), 
DraftRound numeric,
Rk numeric,
FPTSRounded numeric
)

Insert Into #FantasyData
Select adp.PlayerID, adp.ADP, adp.Year, adp.Name, adp.Position, adp.DraftRound, fpts.Rk, fpts.FPTSRounded
From ESPNFF.dbo.ADPFinal adp
Left Join ESPNFF.dbo.FPTSFinal fpts
	on adp.PlayerID = fpts.ID
	and adp.Year = fpts.Year
order by 6, 3

Select *
From #FantasyData
order by 6, 3

--Changing all null values according to ideas specified above
Update #FantasyData
Set Rk = 300
Where Rk IS Null; 

Update #FantasyData
Set FPTSRounded = 100
Where FPTSRounded IS Null; 

--Check to see if all Null values were successfully changed

Select *
From #FantasyData
--where FPTSRounded is null
order by 6, 3

--This temp table is especially useful for us given the fact that we need to bring it into Excel and then into Tableau
--because of our restrictions set by Tableau Public