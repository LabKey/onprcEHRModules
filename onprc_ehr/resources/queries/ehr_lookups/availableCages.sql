SELECT
c.room,
c.cage,
c.cageType,
lc.cage as 'leftCage',

--if the divider on the left-hand cage is separating, then these cages are separate
--and should be counted.  if there's no left-hand cage, always include
CASE
  WHEN lc.divider.countAsSeparate IS NOT NULL THEN lc.divider.countAsSeparate
  ELSE true
END as isAvailable

FROM ehr_lookups.cage c
--find the cage located to the left
LEFT JOIN ehr_lookups.cage lc ON (c.room = lc.room)

