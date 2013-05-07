PARAMETERS(StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
  d.Id,

  GROUP_CONCAT(DISTINCT h1.room, chr(10)) as birthRoom,
  GROUP_CONCAT(DISTINCT h1.room.housingType.value, chr(10)) as birthRoomType,

  GROUP_CONCAT(DISTINCT h2.room, chr(10)) as allRooms,
  GROUP_CONCAT(DISTINCT h2.room.housingType.value, chr(10)) as allRoomTypes,

  max(StartDate) as startDate,
  max(EndDate) as endDate,

  CASE
    WHEN d.id.age.ageInDays = 0 THEN 1
    ELSE 0
  END as bornDead,

  CASE
    WHEN (d.death IS NOT NULL AND d.id.age.ageInDays < 365) THEN 1
    ELSE 0
  END as diedBeforeOneYear,

  CASE
    WHEN d.id.age.ageInDays < 365 AND d.death IS NULL THEN 1
    ELSE 0
  END as underOneYrOld,

FROM study.demographics d

JOIN study.housing h1 ON (h1.id = d.Id AND h1.date <= d.birth AND h1.enddateTimeCoalesced >= d.birth)

JOIN study.housing h2 ON (h2.id = d.Id AND h2.dateOnly <= EndDate AND h2.enddateCoalesced >= StartDate)

WHERE cast(d.birth as date) >= StartDate AND cast(d.birth as date) <= EndDate

GROUP BY d.id, d.id.age.ageInDays, d.death