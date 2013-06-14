/*
 * Copyright (c) 2010-2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
-- d.id.curLocation.room.area as CurrentArea,
-- d.id.curLocation.room as CurrentRoom,
-- d.id.curLocation.cage as CurrentCage,
d.id,
d.calculated_status,
s.*
-- s.lsid || '||' || s.date as primaryKey2,
-- s.objectid || '||' || s.date as primaryKey,
--(SELECT max(d.qcstate) as label FROM study.drug d WHERE (s.objectid || '||' || s.date) = d.treatmentid) as treatmentStatus,
--(SELECT max(taskId) as taskId FROM study.drug d WHERE (s.objectid || '||' || s.date) = d.treatmentid) as taskId


FROM study.demographics d JOIN (

SELECT
  s.*,
  timestampadd('SQL_TSI_MINUTE', ((s.hours * 60) + s.minutes), s.origDate) as date,
  CASE
    WHEN (hours >= 6 AND hours < 16) THEN 'AM'
    WHEN (hours < 6 OR hours >= 16) THEN 'PM'
    ELSE 'Other'
  END as timeOfDay,

  ((s.hours * 60) + s.minutes) as timeOffset

FROM (

SELECT
  t1.lsid,
  t1.objectid,
  t1.dataset,
  t1.id as animalid,

  coalesce(tt.time, ft.hourofday) as time,
  (coalesce(tt.time, ft.hourofday) / 100) as hours,
  (((coalesce(tt.time, ft.hourofday) / 100.0) - floor(coalesce(tt.time, ft.hourofday) / 100)) * 100) as minutes,
  dr.date as origDate,
  --ft.timedescription as timeOfDay,
  CASE
    WHEN (tt.time IS NULL) THEN 'Default'
    ELSE 'Custom'
  END as timeType,

  coalesce(sc.primaryCategory, 'Medication') as category,
  t1.category as treatmentCategory,

  t1.frequency.meaning as frequency,
  t1.date as StartDate,
  timestampdiff('SQL_TSI_DAY', t1.date, curdate()) as daysElapsed,
  t1.enddate,
  --t1.duration,
  t1.project,
  t1.meaning,
  t1.code,

  t1.volume,
  t1.vol_units,
  t1.concentration,
  t1.conc_units,
  t1.amount,
  t1.amount_units,
  t1.amountWithUnits,
  t1.dosage,
  t1.dosage_units,
  t1.qualifier,

  t1.route,
  t1.reason,
  t1.performedby,
  t1.remark,
  --t1.description,

  t1.qcstate

FROM ehr_lookups.dateRange dr

JOIN study."Treatment Orders" t1
  ON (dr.dateOnly >= t1.dateOnly and dr.dateOnly <= t1.enddateCoalesced AND
    mod(timestampdiff('SQL_TSI_DAY', curdate(), dr.dateOnly), t1.frequency.intervalindays) = 0
  )

LEFT JOIN ehr.treatment_times tt ON (tt.treatmentid = t1.objectid)
LEFT JOIN ehr_lookups.treatment_frequency_times ft ON (ft.frequency = t1.frequency.meaning AND tt.rowid IS NULL)
LEFT JOIN ehr_lookups.snomed_subset_codes sc ON (sc.code = t1.code AND sc.primaryCategory = 'Diet')

WHERE t1.date is not null AND t1.qcstate.publicdata = true

) s

) s ON (s.animalid = d.id)

WHERE d.calculated_status = 'Alive'