/*Updatge to user onprc EHR*/
SELECT a.datecreated,
    hour (Now()) AS CurrentHour,
    hour (a.dateCreated) as BVTime,
    Case When hour (a.dateCreated) != hour (Now()) then 'out of synch'
    When hour (a.dateCreated) = hour (Now()) then 'In Synch'
End As AvailableBloodData,
	DayofMonth(a.dateCreated) as MOnthDay,
DayOfMonth(curDate()) as CurrentDay


FROM AvailableBloodVolume a
where  DayofMonth(a.dateCreated)= DayOfMonth(curDate())
and hour (a.dateCreated) != hour (Now())