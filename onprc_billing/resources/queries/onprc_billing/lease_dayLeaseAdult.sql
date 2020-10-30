Select
a.id,
a.date,
a.enddate,
a.projectedrelease,
a.assigncondition,
a.projectedReleaseCondition,
TimeStampDiff('SQL_TSI_Day',a.date,a.projectedRelease) as LengthofLEase,
Case
	When a.assigncondition = a.projectedReleaseCondition then 'No'
	When a.assigncondition != a.projectedReleaseCondition then 'Yes'

End as DayLeaseConditionChange


from study.assignment a
--where a.projectedRelease is not null
where  (a.projectedRelease is not null and a.projectedRelease > a.date)
--and TimeStampDiff('SQL_TSI_Day',a.date,a.projectedRelease)<=15