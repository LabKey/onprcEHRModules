SELECT
  t.Id,
  t.dateOfLastCageHousing,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastCageHousing, now()) as daysSinceLastCageHousing,
  t.dateOfLastGroupHousing,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastGroupHousing, now()) as daysSinceLastGroupHousing,
  t.dateOfLastCagemate,
  timestampdiff('SQL_TSI_DAY', t.dateOfLastCagemate, now()) as daysSinceLastCagemate

FROM (
SELECT
  h.Id,
  MAX(CASE
    WHEN h.room.housingType.value = 'Cage Location' THEN h.enddateTimeCoalesced
    ELSE null
  END) as dateOfLastCageHousing,
  MAX(CASE
    WHEN h.room.housingType.value = 'Group Location' THEN h.enddateTimeCoalesced
    ELSE null
  END) as dateOfLastGroupHousing,
  max(h2.date) as dateOfLastCagemate

FROM study.housing h
LEFT JOIN study.housing h2
  ON (h2.room = h.room AND h.Id != h2.Id AND (h.cage = h2.cage OR (h2.cage IS NULL AND h.cage IS NULL)))

GROUP BY h.Id

) t