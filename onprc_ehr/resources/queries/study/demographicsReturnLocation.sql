SELECT
  t.Id,
  GROUP_CONCAT(t.returnLocation, chr(10)) as returnLocation

FROM (
SELECT
  d.Id,
  CASE
    WHEN gm.groupId.majorityLocation IS NOT NULL THEN (gm.groupId.name || ': ' || gm.groupId.majorityLocation.majorityLocation)
    WHEN cl.prevRoom IS NOT NULL THEN ('Previous Location: ' || cl.prevLocation)
    ELSE 'Unknown'
  END as returnLocation

FROM study.demographics d

LEFT JOIN ehr.animal_group_members gm ON (d.Id = gm.Id AND gm.isActive = true)

LEFT JOIN study.demographicsCurrentLocation cl ON (cl.Id = d.Id)

WHERE d.calculated_status = 'Alive'

) t

GROUP BY t.Id