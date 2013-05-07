PARAMETERS(Room CHAR)

SELECT
  b.id.demographics.species,

  count(b.Id) as totalIds,
  sum(b.bornDead) as totalBornDead,
  sum(b.diedBeforeOneYear) as totalDiedBeforeOneYear,
  count(b.Id) - sum(b.diedBeforeOneYear) as totalSurvivedOneYear,

  max(StartDate) as startDate,
  max(EndDate) as endDate,
  max(Room) as room,

FROM study.birthRateData b

WHERE (Room IS NULL OR b.birthRoom = Room)

GROUP BY b.id.demographics.species