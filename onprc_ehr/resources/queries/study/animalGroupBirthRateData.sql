PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  d.Id,

  gm.id as dam,
  gm.groupId,

  GROUP_CONCAT(DISTINCT h1.room, chr(10)) as birthRoom,
  GROUP_CONCAT(DISTINCT h1.room.housingType.value, chr(10)) as birthRoomType,

  max(StartDate) as startDate,
  max(EndDate) as endDate,

  CASE
    WHEN d.id.age.ageInDays = 0 THEN 1
    ELSE 0
  END as bornDead,

  CASE
    WHEN (d.death IS NOT NULL AND d.id.age.ageInDays < 180) THEN 1
    ELSE 0
  END as diedBefore180Days,

  CASE
    WHEN (d.death IS NOT NULL AND d.id.age.ageInDays < 365) THEN 1
    ELSE 0
  END as diedBeforeOneYear,

  CASE
    WHEN (d.id.age.ageInDays < 365 AND d.death IS NULL) THEN 1
    ELSE 0
  END as underOneYrOld,

  CASE
    WHEN (d.id.age.ageInDays < 180 AND d.death IS NULL) THEN 1
    ELSE 0
  END as under180DaysOld,

FROM study.demographics d

JOIN ehr.animal_group_members gm ON (d.Id.parents.dam = gm.id AND gm.date <= EndDate AND gm.enddateCoalesced >= StartDate)

JOIN study.housing h1 ON (h1.id = d.Id AND h1.date <= d.birth AND h1.enddateTimeCoalesced >= d.birth)

WHERE cast(d.birth as date) >= StartDate AND cast(d.birth as date) <= EndDate

GROUP BY d.id, d.id.age.ageInDays, d.death, gm.id, gm.groupId