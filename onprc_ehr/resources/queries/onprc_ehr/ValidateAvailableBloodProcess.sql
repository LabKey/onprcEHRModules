SELECT a.datecreated,
    hour (Now()) AS CurrentHour,
    hour (a.dateCreated) as BVTime,
    Case When hour (a.dateCreated) != hour (Now()) then 'out of synch'
    When hour (a.dateCreated) = hour (Now()) then 'In Synch'
End As AvailableBloodData

FROM labkeyPublic.AvailableBloodVolume a
where  hour (a.dateCreated) != hour (Now())