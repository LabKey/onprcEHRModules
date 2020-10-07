/*-objectives are
IDentify Research versus resource assignments
Identify infant assignments (determine if Born to resource Mom)
2018-12-21 Added the folllowing to the mix
PI Purchased NHP is code in studyflags to look for
Need to determine if this is a day lease
Add Column for Credit To
Lease Type - Reqds from the query for leases and populates the lease sequnce to use
??Is there a benefit to having a query that reads lease charges from the
*/
PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT distinct a.Id,
Case
	When a.id in (Select f.id from study.flags f where (f.id = a.id and f.flag.value = 'PI Purchased NHP' and f.enddate is Null)) then  'yes'
	else 'No'
End as ResearchOwned,
a.project,
a.project.account as ProjectAlias,

--determine age at time of assignment
a.ageAtTime.AgeAtTime as AgeAtAssignment,
a.id.age.ageinyears,
Case when a.ageAtTime.AgeAtTime <1 then 'infant'
	Else 'adult'
	End as AgeGroup,
Case when Cast(a.date as Date) = cast(d.date as date) then 'yes'
	Else 'no'
	End as BirthAssignment,
Case
	when t.id is not null and t.tmbDamStatus <> 'Dam TMB Only' then 'TMB Infant with Dam'
	when t.id is not null and t.tmbDamStatus = 'Dam TMB Only' then 'TMB Birth Dam Not on Research Project'
	--when ( Cast(a.date as Date) = Cast(a.id.birth.date as Date)  and t.id is not null) and a.project != t.DamAssignment then 'TMB Birth Dam Not on Research Project'
	when (d.use_Category is null and  Cast(a.date as Date) = cast(d.date as date)) then 'NonResourceBirth'
	when (d.use_Category is not Null and Cast(a.date as Date) = cast(d.date as date)) then 'Born to Resource Dam'
	else 'Non Birth Assignment'
	End as BirthType,

Case
	when ( a.date = a.id.birth.date and t.id is not null) then 'TMB Birth'
	when a.project.use_category = 'Research' then 'Research'
	Else a.project.use_category
end
as	AssignmentType,
--determine if day lease -
Case
	When (TimestampDiff('SQL_TSI_DAY',a.date,a.enddate) < 15 and TimestampDiff('SQL_TSI_DAY',a.date,a.enddate) >= 0) then 'Yes'
	When TimestampDiff('SQL_TSI_DAY',a.date,a.projectedRelease) < 0 then 'Bad Date Entry'
	When TimestampDiff('SQL_TSI_DAY',a.date,a.projectedRelease) < 15 then 'Yes'
	When a.projectedRelease is null then 'No Defined Projected Release Date'
	Else 'No'
End as DayLease,

--build in to handle bad code
Case
	when a.enddate is not null and TimestampDiff('SQL_TSI_DAY',a.date,a.enddate) < 15  then TimestampDiff('SQL_TSI_DAY',a.date,a.enddate)
    when a.projectedRelease is not null and TimestampDiff('SQL_TSI_DAY',a.date,a.projectedRelease) < 15 and TimestampDiff('SQL_TSI_DAY',a.date,a.projectedRelease) >=0 then 	TimestampDiff('SQL_TSI_DAY',a.date,a.projectedRelease)
	Else Null
	End as DayLeaseLength,

--need to determine if this is a dual assignment so we can tag who receives the credit

Case
	when (Select Count(a2.project.name) from study.assignment a2 where (a2.id = a.id and a.project <> a2.project and a2.enddate is null and a2.date <= a.date)) > 2 then 'Over 2 Assignments'
	when (Select Count(a2.project.name) from study.assignment a2 where (a2.id = a.id and a.project <> a2.project and a2.enddate is null and a2.date <= a.date)) = 2 then
  'Dual Assigned'

End as MultipleAssignments,
 --(Select a2.project.name from study.assignment a2 where (a2.id = a.id and a.project <> a2.project and a2.enddate is null and a2.date <= a.date)) as DualAssignment,



a.date,
a.projectedRelease,
a.enddate,
a.datefinalized,
a.assignCondition,
a.projectedReleaseCondition,
a.releaseCondition,
a.releaseType,
a.remark,
a.project.account As alias

--This looks at situations where an animal is being dual assigned and credits the correct resource
--Case



--End as CreditTo,


FROM study.assignment a
left outer join study.tmbBirth t on a.id = t.id
left join study.birth_resourceDam d on a.id  =  d.id
--left outer join study.tmbdam t on t.id = a.id.birth.dam
where a.date >= startDate and (a.date <= enddate or a.enddate is null)
and a.id not like  '[a-z]%'