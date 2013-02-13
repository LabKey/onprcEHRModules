SELECT
 pc.room,
 pc.effectiveCage as cage,
 count(h.id) as totalAnimals,
 group_concat(h.id, chr(10)) as animals,
 group_concat(DISTINCT h.cage) as cagesOccupied,
 group_concat(DISTINCT pc.cage) as cagesJoined,

FROM ehr_lookups.pairedCages pc
left join study.housing h ON (pc.room = h.room AND pc.cage = h.cage AND h.qcstate.publicdata = true and h.enddate is null and h.cage is not null)

GROUP BY pc.room, pc.effectiveCage