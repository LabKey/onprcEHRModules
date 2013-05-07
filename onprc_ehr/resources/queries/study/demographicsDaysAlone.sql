/*
 * Copyright (c) 2010-2011 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
--this query displays all animals co-housed with each housing record
--to be considered co-housed, they only need to overlap by any period of time

SELECT

h1.id,
h1.room,
h1.cage,
count(h2.id) as cageMates,
group_concat(h2.id, chr(10)) as pairedAnimals,
CASE
  --never had a roommate
  WHEN count(h2.id) = 0 then min(h1.date)
  --has an active roommate
  WHEN (max(coalesce(h2.enddate, now())) = now()) OR (max(h2.date) >= max(coalesce(h2.enddate, now())))
    THEN null
  ELSE
    max(h2.enddate)
END as AloneSince,

cast(
CASE
  --never had a roommate
  WHEN count(h2.id) = 0
    then TIMESTAMPDIFF('SQL_TSI_DAY', min(h1.date), now())
  --has an active roommate
  WHEN (max(coalesce(h2.enddate, now())) = now()) OR (max(h2.date) >= max(coalesce(h2.enddate, now())))
    THEN 0
  ELSE
    TIMESTAMPDIFF('SQL_TSI_DAY', max(h2.enddate), now())
END as integer) as DaysAlone,

FROM study.demographics d
JOIN study.Housing h1 ON (d.id = h1.id)

--find any overlapping housing record
LEFT JOIN study.Housing h2 ON (
    h2.Date <= h1.enddateCoalesced
    AND h2.enddateCoalesced > h1.date
    AND h1.id != h2.id
    AND h1.room = h2.room
    AND ((h1.effectiveCage.effectiveCage = h2.effectiveCage.effectiveCage) OR h1.cage is null AND h2.cage is null)
)

-- --join to vet exemptions
-- LEFT JOIN study.assignment a
--   --ON (h1.id = a.id AND a.EndDate IS NULL and a.project.title LIKE '%pairing exempt%')
--   ON (h1.id = a.id AND a.EndDate IS NULL and a.project IN (19980301,19970301,20001001,20031101,20060202))

WHERE d.calculated_status = 'Alive'
AND h1.qcstate.publicdata = true
AND h2.qcstate.publicdata = true
AND h1.enddate IS NULL

--filter out pairing exempt animals
--AND a.id IS NULL

GROUP BY h1.id, h1.room, h1.cage

-- HAVING
-- max(a.value) IS NULL
