SELECT
  g.rowid,
  g.name,
  group_concat(t2.room) as majorityLocation,
  max(t2.total) as total

FROM ehr.animal_groups g

JOIN (
  SELECT
    t1.groupId,
    max(t1.total) as total
  FROM (
  SELECT
    m.groupId,
    m.Id.curlocation.room,
    count(*) as total
  FROM ehr.animal_group_members m
  WHERE m.isActive = true
  GROUP BY m.groupId, m.Id.curlocation.room
  ) t1
  GROUP BY t1.groupId
) t ON (t.groupId = g.rowid)

JOIN (
   SELECT
     m.groupId,
     m.Id.curlocation.room,
     count(*) as total
   FROM ehr.animal_group_members m
   WHERE m.isActive = true
   GROUP BY m.groupId, m.Id.curlocation.room
) t2 ON (t2.groupId = t.groupId AND t.total = t2.total)

GROUP BY g.rowid, g.name