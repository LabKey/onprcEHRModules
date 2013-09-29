SELECT
  d.Id,
  d.Id.parents.dam,
  gm.groupId as damGroupId,
  gm2.groupId as offspringGroupId,
  d.birth,
  CASE
    WHEN gm2.Id IS NULL THEN false
    ELSE true
  END as matchesDamGroup

FROM study.demographics d

--find dams with group assignments on date of birth
JOIN ehr.animal_group_members gm ON (d.Id.parents.dam = gm.id AND gm.dateOnly <= cast(d.birth as date) AND gm.enddateCoalesced >= cast(d.birth as date))

LEFT JOIN ehr.animal_group_members gm2 ON (gm.groupId = gm2.groupId AND d.Id = gm2.Id AND gm2.dateOnly <= cast(d.birth as date) AND gm2.enddateCoalesced >= cast(d.birth as date))

