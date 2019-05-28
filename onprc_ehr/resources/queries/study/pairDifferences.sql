/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
PARAMETERS(Date1 TIMESTAMP, Date2 TIMESTAMP)

SELECT
  t.Id,
  t.calculated_status,

  CASE
    WHEN t.animalsInCage1 = t.animalsInCage2 THEN false
    WHEN (t.animalsInCage1 IS NULL AND t.animalsInCage2 IS NULL) THEN false
    ELSE true
  END as hasChanged,

  CASE
    WHEN (t.animalsInCage1 = t.animalsInCage2) THEN null
    WHEN (t.animalsInCage1 IS NULL AND t.animalsInCage2 IS NULL) THEN null
    WHEN (t.room2 IS NULL) THEN 'Arrival or Birth'
    --WHEN (t.room1 IS NULL) THEN 'Death or Departure'
    WHEN (t.housingType1 = 'Cage Location' AND t.housingType2 = 'Cage Location')  THEN 'Changed Cagemates'
    WHEN (t.housingType1 = 'Cage Location' AND t.housingType2 != 'Cage Location')  THEN 'Left Group'
    WHEN (t.housingType1 != 'Cage Location' AND t.housingType2 = 'Cage Location')  THEN 'Joined Group'
    WHEN (t.housingType1 != 'Cage Location' AND t.housingType2 != 'Cage Location')  THEN 'Group Members Changed'
    ELSE 'Unknown'
  END as changeType,

  t.room1,
  t.cage1,
  t.housingType1,

  t.room2,
  t.cage2,
  t.housingType2,

  t.animalsInCage1,
  t.animalsInCage2,
  (SELECT count(*) FROM study.pairings p WHERE p.Id = t.Id AND p.dateOnly = CAST(Date2 AS DATE)) as pairObservations,
  Date1 as date1,
  Date2 as date2

FROM (

SELECT
  d.Id,
  d.calculated_status,
  h1.room as room1,
  h1.room.housingType.value as housingType1,
  h1.cage as cage1,
  --full pairs on the first date
  (SELECT CASE WHEN sum(CASE WHEN h2.room.housingType.value = 'Cage Location' THEN 1 ELSE 0 END) = 0 THEN 'Group Housed' ELSE group_concat(distinct h2.Id) END as ids FROM study.housing h2 WHERE
    --h1.Id != h2.Id AND
    h1.room = h2.room AND
    (h1.cage = h2.cage OR (h1.cage IS NULL AND h2.cage IS NULL)) AND
    h2.date <= Date1 and h2.enddateTimeCoalesced > Date1
  ) as animalsInCage1,

  h3.room as room2,
  h3.room.housingType.value as housingType2,
  h3.cage as cage2,
  --full pairs on the second date
  (SELECT CASE WHEN sum(CASE WHEN h4.room.housingType.value = 'Cage Location' THEN 1 ELSE 0 END) = 0 THEN 'Group Housed' ELSE group_concat(distinct h4.id) END as ids FROM study.housing h4 WHERE
    --h3.Id != h4.Id AND
    h3.room = h4.room AND
    (h3.cage = h4.cage OR (h3.cage IS NULL AND h3.cage IS NULL)) AND
    h4.date <= Date2 and h4.enddateTimeCoalesced > Date2
  ) as animalsInCage2

FROM study.demographics d

--housing on the first date
JOIN study.housing h1 ON (
--LEFT JOIN study.housing h1 ON (
    d.Id = h1.Id AND
    h1.date <= Date1 and (h1.enddateTimeCoalesced > Date1)
)

--now find housing on the second date (assumed to be the earlier date)
LEFT JOIN study.housing h3 ON (
  d.Id = h3.Id AND
  h3.date <= Date2 and (h3.enddateTimeCoalesced > Date2)
)

--date1 should always be after date2, so ensure we dont get abnormal results
--WHERE Date1 >= Date2
-- AND (h1.Id is not null or h3.Id is not null)
--WHERE (d.death IS NULL OR d.death <= Date2)

) t