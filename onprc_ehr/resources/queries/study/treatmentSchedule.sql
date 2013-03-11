/*
 * Copyright (c) 2010-2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
*,
-- s.lsid || '||' || s.date as primaryKey2,
-- s.objectid || '||' || s.date as primaryKey,
-- null as initials,
-- null as restraint,
-- null as time,
--(SELECT max(d.qcstate) as label FROM study.drug d WHERE (s.objectid || '||' || s.date) = d.parentid) as treatmentStatus,
--(SELECT max(taskId) as taskId FROM study.drug d WHERE (s.objectid || '||' || s.date) = d.parentid) as taskId


FROM (

SELECT
  t1.lsid,
  t1.objectid,
  t1.dataset,
  t1.id,
  t1.id.curLocation.room as CurrentArea,
  t1.id.curLocation.room as CurrentRoom,
  t1.id.curLocation.cage as CurrentCage,

  timestampadd('SQL_TSI_HOUR', ft.hourofday, d.date) as date,
  ft.timedescription as TimeOfDay,

  t1.frequency.meaning as frequency,
  t1.date as StartDate,
  t1.enddate,
  t1.project,
  t1.meaning,
  t1.code,

--   case
--     WHEN (t1.volume is null or t1.volume = 0)
--       THEN null
--     else
--       (CONVERT(t1.volume, float) || ' ' || t1.vol_units)
--   END as volume2,
  t1.volume,
  t1.vol_units,
--   case
--     WHEN (t1.concentration is null or t1.concentration = 0)
--       THEN null
--     else
--       (CONVERT(t1.concentration, float) || ' ' || t1.conc_units)
--   END as conc2,
  t1.concentration,
  t1.conc_units,
--   case
--     WHEN (t1.amount is null or t1.amount = 0)
--       THEN null
--     else
--       (CONVERT(t1.amount, float) || ' ' || t1.amount_units)
--   END as amount2,
  t1.amount,
  t1.amount_units,
--   case
--     WHEN (t1.dosage is null or t1.dosage = 0)
--       THEN null
--     else
--       (CONVERT(t1.dosage, float) || ' ' || t1.dosage_units)
--   END as dosage2,
  t1.dosage,
  t1.dosage_units,
  t1.qualifier,

  t1.route,
  t1.performedby,
  t1.remark,
  t1.description,
--   CASE WHEN t1.enddate is null AND t1.meaning IS null AND t1.code.meaning IS null THEN
--     ('Drug: ' || t1.code)
--   WHEN t1.enddate is null AND t1.meaning IS NOT null THEN
--     ('Drug: ' || t1.meaning || ' (' || t1.code || ')')
--   WHEN t1.enddate is null AND t1.code.meaning IS NOT null THEN
--     ('Drug: ' || t1.code.meaning || ' (' || t1.code || ')')
--   WHEN t1.enddate is not null AND t1.meaning IS NOT null THEN
--     ('Drug: ' || t1.meaning || ' (' || t1.code || ')' || chr(10) || 'End Date: ' || convert(t1.enddate, varchar))
--   WHEN t1.enddate is not null AND t1.code.meaning IS NOT null THEN
--     ('Drug: ' || t1.code.meaning || ' (' || t1.code || ')' || chr(10) || 'End Date: ' || convert(t1.enddate, varchar))
--   ELSE
--     ('Drug: ' || t1.code || chr(10) || 'End Date: ' || convert(t1.enddate, varchar))
--   END AS description2,

  t1.qcstate,

FROM ehr_lookups.next30Days d

--TODO: we should clean this up and make it more data-driven
LEFT JOIN study."Treatment Orders" t1
  ON (d.date >= t1.date and cast(d.date as date) <= t1.enddateCoalesced AND (
  --daily
  (t1.frequency.meaning='Daily - AM' OR t1.frequency.meaning='Daily - AM/PM' OR t1.frequency.meaning='Daily - AM/PM/Night' OR t1.frequency.meaning='Daily - PM' OR t1.frequency.meaning='Daily - Night' OR t1.frequency.meaning='Daily - AM/Night' OR t1.frequency.meaning='Daily - Noon' OR t1.frequency.meaning='Daily - Any Time')
  OR
  --monthly
  --always 1st tues
  (t1.frequency.meaning='Monthly' AND d.dayofmonth<=7 AND d.dayofweek=3)
  OR
  --weekly
  --always on same day as start date
  (t1.frequency.meaning='Weekly' AND d.dayofweek=dayofweek(t1.date))
  OR
  --alternating days.  relative to start date
  (t1.frequency.meaning like '%Alternating Days%' AND mod(d.dayofyear,2)=mod(cast(dayofyear(t1.date) as integer),2))
  ))

LEFT JOIN ehr_lookups.treatment_frequency_times ft ON (ft.frequency = t1.frequency)

-- LEFT JOIN study.assignment a1
--   ON (a1.project = t1.project AND a1.dateOnly <= cast(d.date as date) AND a1.enddateCoalesced >= CAST(d.date as date) AND a1.id = t1.id)

WHERE t1.date is not null AND t1.qcstate.publicdata = true

) s

