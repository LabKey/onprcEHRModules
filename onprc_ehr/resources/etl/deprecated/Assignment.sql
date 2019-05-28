/*
 * Copyright (c) 2012-2014 LabKey Corporation
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
Select
	cast(af.AnimalID as nvarchar(4000)) as Id,
	af.ProjectID as Project,
	--RefProj.Title,

		-----    Ref_ProjectsIacuc (ProjectID)		
	AssignDate as Date,
--	ReleaseDate as Enddate,

	coalesce(ReleaseDate, q.deathdate, q.departuredate) as enddate ,
	estimatedreleasedate as projectedRelease,

	AssignPool as assignCondition,							--Ref_Pool
	EstimatedReleasePool as projectedReleaseCondition,		--Ref_Pool
	ActualReleasePool as releaseCondition,			--

--  --  --NOTE: according to raymond replacementFlag is not in use and can be ignored
-- 	ReplacementFlag as ReplacementFlagRaw,
-- 	s1.Value as ReplacementFlag,

	af.objectid
	--af.ts as rowversion

From Af_Assignments af

LEFT JOIN Ref_ProjectsIacuc RefProj ON (RefProj.ProjectID = af.ProjectID)
LEFT JOIN Ref_Pool p1 ON (p1.PoolCode = AssignPool)
LEFT JOIN Ref_Pool p2 ON (p2.PoolCode = EstimatedReleasePool)
LEFT JOIN Ref_Pool p3 ON (p3.PoolCode = ActualReleasePool)
LEFT JOIN Sys_Parameters s1 ON (field = 'ReplacementFlag' and Flag = ReplacementFlag)
left join Af_Qrf q on (q.animalid = af.animalid)

WHERE (af.ts > ? or q.ts > ?)
