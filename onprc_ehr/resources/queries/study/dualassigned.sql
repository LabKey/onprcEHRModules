/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT a.Id,
a.id.demographics.gender,
--
a.project as Project1,
a2.project as Project2,
Case
	when lower(a.project.use_category) != 'research' then a.project
	when lower(a2.project.use_category) != 'research' then a2.project
	else Null
	end as project,

Case
	when lower(a.project.use_category) != 'research' then a.project.account.alias
	when lower(a2.project.use_category) != 'research' then a2.project.account.alias
	else Null
	end as projectAccount,
Case
	when lower(a.project.use_category) != 'research' then a.project.displayname
	when lower(a2.project.use_category) != 'research' then a2.project.displayName
	else Null
	end as projectName,


Case
	when lower(a.project.use_category) != 'research' then a.project.use_category
	when lower(a2.project.use_category) != 'research' then a2.project.use_category
	else Null
	end as projectCategory,
--date should be the assignment date of the resource
Case
	when lower(a.project.use_category) != 'research' then a.date
	when lower(a2.project.use_category) != 'research' then a2.date
	else Null
	end as date,

Case
	when lower(a.project.use_category) != 'research' then a.projectedRelease
	when lower(a2.project.use_category) != 'research' then a2.projectedRelease
	else Null
	end as projectedRelease,
Case
	when lower(a.project.use_category) != 'research' then a.enddate
	when lower(a2.project.use_category) != 'research' then a2.enddate
	else Null
	end  as enddate,

Case
	when lower(a.project.use_category) != 'research' then a.assignCondition
	when lower(a2.project.use_category) != 'research' then a2.assignCondition
	else Null
	end  as assignCondition,

Case
	when lower(a.project.use_category) != 'research' then a.projectedReleaseCondition
	when lower(a2.project.use_category) != 'research' then a2.projectedReleaseCondition
	else Null
	end  as projectedReleaseCondition,




--this places the research project as the Dual assigned
Case
	When lower(a2.project.use_category) = 'research' then a2.project
	when lower(a.project.use_category) = 'research' then a.project
	Else Null
	ENd as DualAssignment,
--a2.project as DualAssignment,
Case
	When lower(a2.project.use_category) = 'research' then a2.project.displayName
	when lower(a.project.use_category) = 'research' then a.project.DisplayName
	Else Null
	ENd as DualName,

--this places the research project as the Dual assigned
Case
	When lower(a2.project.use_category) = 'research' then a2.project.use_category
	when lower(a.project.use_category) = 'research' then a.project.use_category
	Else Null
	ENd as DualProjectCategory,
Case
	When lower(a2.project.use_category) = 'research' then a2.date
	when lower(a.project.use_category) = 'research' then a.date
	Else Null
	ENd as DualStartDate,

Case
	When lower(a2.project.use_category) = 'research' then a2.projectedRelease
	when lower(a.project.use_category) = 'research' then a.projectedRelease
	Else Null
	ENd as DualProjectedRelease,

Case
	When lower(a2.project.use_category) = 'research' then a2.enddate
	when lower(a.project.use_category) = 'research' then a.enddate
	Else Null
	ENd as DualEndDate





FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a2 on a.id = a2.id
where ( a.project <> a2.project) and lower(a.project.use_category) != 'research'
