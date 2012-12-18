/*
Birth_FosterMom

Created by: Lakshmi Kolli	Date: 8/7/2012

Tested by: 			Date:
       Raymond Blasa                8/23/2012

*/
SELECT
	--Searchkey as SearchKey,
	cast(Infant_ID as nvarchar(4000)) as Id,
	cast(Foster_Mom as nvarchar(4000)) as Dam,
	Foster_Start_Date as date,
	Foster_End_Date as enddate,
	objectid
--	ts as ts,

From Birth_FosterMom

WHERE ts > ?
