/*
MasterProblemList

Created by: Lakshmi Kolli	Date: 8/16/2012

Tested by: 			Date:
          Raymond Blasa             8/21/2012

*/

 SELECT
	cast(ml.AnimalID as nvarchar(4000)) as Id,
	ML.DateCreated as date,
	ML.DateDisabled as enddate,

	c.objectid as parentid,
	s1.Value as category,
	ml.objectid

FROM MasterProblemList ML
left join Af_Case c on (c.CaseID = ml.CaseID)
LEFT JOIN Sys_parameters s1 ON (s1.Field = 'MasterProblemList' and s1.Flag = MasterProblem)

WHERE ml.ts > ?