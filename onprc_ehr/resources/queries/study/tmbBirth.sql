--created 8/22/2018 by jonesga
--purpose to identify dual assigned animals for use with lease fee queries

--We are now showing TMB assignments
--need to determine whether the Dam was assigned to the
--We are now showing TMB assignments
--need to determine whether the Dam was assigned to the
--Update 3/11/2019 Added to Test
Select distinct
b.id,
b.date,
--going to want to add the NonTMB Assignment data to the project details
a.project,
a.date as InfantAssignmentDate,
--(Select a3.id from study.assignment a3 where a3.id = b.dam and a3.project = a.project and a3.date <= b.date and a3.enddate > b.date  or a3.enddate is null and a3.project <> 559) as DamAssignment,
b.dam,
t.id as TMBDam,
t.date as TMBAssignedDate,
t.endDate as TMBEndDate,

da.dualassignment,
da.dualstartDate,
da.dualEndDate,

t.enddate as RemovalDate,
--determine how the dam was assigned at the time of birth
Case
	When a.project is not Null and b.dam in (Select a2.id from study.assignment a2 where a2.id = b.dam and a2.project = a.project and a2.date <= b.date and a2.enddate > b.date  or a2.enddate is null) then 'Dam on Project'
	When b.dam in (Select a2.id from study.assignment a2 where a2.id = b.dam and a2.project <> a.project and a2.date <= b.date and a2.enddate > b.date  or a2.enddate is null) then 'Dam TMB Only'
	--When then ' Dam TMB Only'
    else 'Undetermined'
	end as TMBDamStatus
-- WHEN MOM NOT on other project except TMB we will look for infant assignment within 30 days of birth to credit otherwisse it is P51
--Determine if animal was not immediately assigned to a Research project and then assigned to a Research project within 30 days of its birth


from study.birth b join study.tmbdam t on b.dam = t.id
	left join study.assignment a on (a.id = b.id and a.dateOnly = b.dateOnly)
	left outer join study.dualAssigned da on (da.id = b.dam and a.project = da.dualAssignment
                                              and (da.dualstartDate < b.date and da.dualendDate > b.date))
where b.date > t.date