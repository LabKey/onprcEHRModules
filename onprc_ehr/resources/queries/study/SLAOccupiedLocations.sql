SELECT
r.room,
r.building,
--c.room,
c.Species,
c.Date,
c.Animal_Count,
c.Cage_Count,
c.recentdate
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr_lookups.rooms r
Left join Site.{substitutePath moduleProperty('SLA','SLAContainer')}.sla.SLAMostRecentCensus c on r.room = c.room
Where r.housingType.value = 'Rodent Location'
and r.datedisabled is null