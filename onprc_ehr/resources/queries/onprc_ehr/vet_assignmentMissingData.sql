Select
'Research Protocol_Missing' as MissingItem,
a.project.protocol.displayName as Item,
v.protocol.displayName as Vet_AssignedItem,
Count(a.participantId) as totalNHps
from study.assignment a left  outer join vet_assignment  v on a.project.protocol = v.protocol.protocol
where a.project.use_category = 'Research' and a.enddate is null and v.protocol.displayName is null
group by a.project.protocol.displayname,v.protocol.displayName

Union

Select
'Resource Protocol_Missing' as MissingItem,
a.project.protocol.displayName as Item,
v.protocol.displayName as Vet_AssignedItem,
Count(a.participantId) as totalNHps
from study.assignment a left  outer join vet_assignment  v on a.project.protocol = v.protocol.protocol
where a.project.use_category != 'Research'and a.enddate is null and v.protocol.displayName is null
group by a.project.protocol.displayname,v.protocol.displayName
Union

Select
'Area_Missing' as MissingItem,
a.area as Item,
v.area as Vet_AssignedItem,
Count(h.ID) as TotalNHPS
from ehr_lookups.areas a left outer join vet_assignment v on a.area = v.area
	left outer join study.housing h on h.room.area = a.area
where v.area is null and h.enddate is null
group by a.area,v.area


Union

Select
'Room_Missing' as MissingItem,
r.room as Item,
v.room as Vet_AssignedItem,
Count(h.id) as totalNHPs
from ehr_lookups.rooms r left outer join vet_assignment v on r.room = v.room
			left outer join study.housing h on h.room = r.room and h.enddate is null
where v.room is null and r.area not in (Select v1.area from vet_assignment v1 where v1.area = r.area)
group by r.room,v.room

union

Select
'NHP No Vet',
v.id,
v.assignedVet,
0
from study.demographicsAssignedVet v where v.assignedvet is null
