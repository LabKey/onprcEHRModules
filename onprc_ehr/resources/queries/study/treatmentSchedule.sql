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
  t1.lsid,
  t1.objectid,
  t1.dataset,
  t1.id as animalid,

  timestampadd('SQL_TSI_HOUR', coalesce(tt.time, ft.hourofday), dr.date) as date,
  ft.timedescription as timeOfDay,
  CASE
    WHEN (tt.time IS NULL) THEN 'Default'
    ELSE 'Custom'
  END as timeType,

  t1.frequency.meaning as frequency,
  t1.date as StartDate,
  t1.enddate,
  t1.duration,
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
  ON (dr.date >= t1.date and dr.dateOnly <= t1.enddateCoalesced AND
    mod(timestampdiff('SQL_TSI_DAY', curdate(), dr.dateOnly), t1.frequency.intervalindays) = 0
  )

LEFT JOIN ehr.treatment_times tt ON (tt.treatmentid = t1.objectid)
LEFT JOIN ehr_lookups.treatment_frequency_times ft ON (ft.frequency = t1.frequency.meaning AND tt.rowid IS NULL)

-- LEFT JOIN study.assignment a1
--   ON (a1.project = t1.project AND a1.dateOnly <= cast(dr.date as date) AND a1.enddateCoalesced >= CAST(dr.date as date) AND a1.id = t1.id)

WHERE t1.date is not null AND t1.qcstate.publicdata = true

) s ON (s.animalid = d.id)

WHERE d.calculated_status = 'Alive'
