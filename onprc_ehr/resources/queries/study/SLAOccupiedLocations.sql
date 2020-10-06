SELECT
r.room,
r.building,
--c.room,
c.Species,
c.Date,
c.Animal_Count,
c.Cage_Count,
c.recentdate
FROM "/ONPRC/EHR".ehr_lookups.rooms r
Left join "/ONPRC/sla".sla.SLAMostRecentCensus c on r.room = c.room
Where r.housingType.value = 'Rodent Location'
and r.datedisabled is null