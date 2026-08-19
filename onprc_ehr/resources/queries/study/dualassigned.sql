SELECT a.Id,
a.id.demographics.gender,
--
a.project as Project1,
a2.project as Project2,
Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.project
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.project
	else Null
	end as project,

Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.project.account.alias
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.project.account.alias
	else Null
	end as projectAccount,
Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.project.displayname
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.project.displayName
	else Null
	end as projectName,


Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.project.use_category
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.project.use_category
	else Null
	end as projectCategory,
--date should be the assignment date of the resource
Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.date
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.date
	else Null
	end as date,

Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.projectedRelease
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.projectedRelease
	else Null
	end as projectedRelease,
Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.enddate
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.enddate
	else Null
	end  as enddate,

Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.assignCondition
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.assignCondition
	else Null
	end  as assignCondition,

Case
	when LOWER(a.project.use_category) != LOWER('Research') then a.projectedReleaseCondition
	when LOWER(a2.project.use_category) != LOWER('Research') then a2.projectedReleaseCondition
	else Null
	end  as projectedReleaseCondition,




--this places the research project as the Dual assigned
Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.project
	when LOWER(a.project.use_category) = LOWER('Research') then a.project
	Else Null
	ENd as DualAssignment,
--a2.project as DualAssignment,
Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.project.displayName
	when LOWER(a.project.use_category) = LOWER('Research') then a.project.DisplayName
	Else Null
	ENd as DualName,

--this places the research project as the Dual assigned
Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.project.use_category
	when LOWER(a.project.use_category) = LOWER('Research') then a.project.use_category
	Else Null
	ENd as DualProjectCategory,
Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.date
	when LOWER(a.project.use_category) = LOWER('Research') then a.date
	Else Null
	ENd as DualStartDate,

Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.projectedRelease
	when LOWER(a.project.use_category) = LOWER('Research') then a.projectedRelease
	Else Null
	ENd as DualProjectedRelease,

Case
	When LOWER(a2.project.use_category) = LOWER('Research') then a2.enddate
	when LOWER(a.project.use_category) = LOWER('Research') then a.enddate
	Else Null
	ENd as DualEndDate





FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a2 on a.id = a2.id
where ( a.project <> a2.project) and LOWER(a.project.use_category) != LOWER('Research')
