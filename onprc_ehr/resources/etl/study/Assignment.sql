/*
 * Copyright (c) 2012 LabKey Corporation
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
	cast(AnimalID as varchar) as Id,
	af.ProjectID as Project,
	--RefProj.Title,

		-----    Ref_ProjectsIacuc (ProjectID)		
	AssignDate as Date,
	ReleaseDate as Enddate,

	--TODO: handle pools
-- 	AssignPool as AssignPool  ,							--Ref_Pool
-- 	p1.ShortDescription as desc1,
-- 	EstimatedReleasePool,		--Ref_Pool
-- 	p1.ShortDescription as desc2,
-- 	ActualReleasePool,			--
-- 	p1.ShortDescription as desc3,


--  --  --NOTE: according to raymond replacementFlag is not in use and can be ignored
-- 	ReplacementFlag as ReplacementFlagRaw,
-- 	s1.Value as ReplacementFlag,

	IDKey as IDKey,

	af.objectid
	--af.ts as rowversion

From Af_Assignments af

LEFT JOIN Ref_ProjectsIacuc RefProj ON (RefProj.ProjectID = af.ProjectID)
LEFT JOIN Ref_Pool p1 ON (p1.PoolCode = AssignPool)
LEFT JOIN Ref_Pool p2 ON (p2.PoolCode = EstimatedReleasePool)
LEFT JOIN Ref_Pool p3 ON (p3.PoolCode = ActualReleasePool)
LEFT JOIN Sys_Parameters s1 ON (field = 'ReplacementFlag' and Flag = ReplacementFlag)

WHERE af.ts > ?