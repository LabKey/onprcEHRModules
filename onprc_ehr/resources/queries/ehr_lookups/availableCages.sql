SELECT
c.room,
c.cage,
c.row,
c.column,
c.cage_type,
lc.cage as leftCage,
lc.cage_type as left_cage_type,
lc.divider,
--lc.divider.countAsSeparate,

--if the divider on the left-hand cage is separating, then these cages are separate
--and should be counted.  if there's no left-hand cage, always include
CASE
  WHEN lc.divider.countAsSeparate = false THEN false
  ELSE true
END as isAvailable

FROM ehr_lookups.cage c
--find the cage located to the left
LEFT JOIN ehr_lookups.cage lc ON (lc.cage_type != 'No Cage' and c.room = lc.room and c.row = lc.row and (c.column - 1) = lc.column)

WHERE c.cage_type != 'No Cage'
