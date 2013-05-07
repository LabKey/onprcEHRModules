SELECT
  t1.groupId,
  group_concat(t1.roomSummary, chr(10)) as roomSummary,
  count(distinct t1.roomSummary) as totalRooms

FROM (

SELECT
  gm.groupId,
  gm.Id.curLocation.room,
  count(distinct gm.id) as totalAnimals,
  gm.Id.curLocation.room || ' (' || cast(count(distinct gm.id) as varchar) || ')' as roomSummary

FROM ehr.animal_group_members gm

WHERE gm.enddateCoalesced >= curdate() and gm.Id.curLocation.area != 'Hospital'
GROUP BY gm.groupId, gm.Id.curLocation.room

) t1

GROUP BY t1.groupId