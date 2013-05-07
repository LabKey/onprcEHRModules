SELECT
  b.groupId,

  count(b.Id) as totalIds,
  count(DISTINCT b.dam) as totalDams,
  sum(b.bornDead) as totalBornDead,
  sum(b.diedBefore180Days) as totalDiedBefore180Days,
  sum(b.diedBeforeOneYear) as totalDiedBeforeOneYear,
  sum(b.under180DaysOld) as totalUnder180DaysOld,
  sum(b.underOneYrOld) as totalUnderOneYrOld,
  count(b.Id) - sum(b.diedBeforeOneYear) as totalSurvivedOneYear,

  max(StartDate) as startDate,
  max(EndDate) as endDate,

FROM study.animalGroupBirthRateData b

GROUP BY b.groupId