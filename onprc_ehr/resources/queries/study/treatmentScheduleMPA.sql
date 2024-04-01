/*
 * Copyright (c) 2015 LabKey Corporation
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

 -- Created by Kollil on 9/25/2023
 Tkt# 9939
 Creating a new alert for this medication. This MPA injection is a post op med category but scheduled once a month.

  */
SELECT
    h.id,
    h.calculated_status,
    --s.TreatmentStatus,
    (SELECT max(d.qcstate.label) as label FROM study.drug d WHERE s.objectid = d.treatmentid and s.date = d.timeordered) as TreatmentStatus,
    h.Id.curLocation.room as room,
    h.Id.curLocation.cage as cage,
    s.date,
    s.startDate,
    s.endDate,
    s.dayselapsed,
    s.category,
    s.code,
    s.code.meaning as medication,
    s.volume,
    s.vol_units,
    s.concentration,
    s.conc_units,
    s.amountWithUnits,
    s.amountAndVolume,
    s.dosage,
    s.dosage_units,
    s.frequency,
    s.route,
    s.reason,
    s.remark,
    s.performedby
FROM study.demographics h JOIN (

    SELECT
        s.animalid, s.TreatmentStatus, timestampadd('SQL_TSI_MINUTE', ((s.hours * 60) + s.minutes), s.origDate) as date, s.objectid,
    s.startdate, s.enddate, s.dayselapsed, s.category, s.code, s.volume, s.vol_units, s.concentration, s.conc_units,
    s.amountWithUnits, s.amountAndVolume, s.dosage, s.dosage_units, s.frequency, s.route, s.reason, s.remark, s.performedby
    FROM (

        SELECT
        t1.objectid,
        t1.id as animalid,
        (coalesce(tt.time, ft.hourofday, (hour(t1.date) * 100)) / 100) as hours,

        CASE
        WHEN (tt.time IS NOT NULL OR ft.hourofday IS NOT NULL) THEN (((coalesce(tt.time, ft.hourofday) / 100.0) - floor(coalesce(tt.time, ft.hourofday) / 100)) * 100)
        ELSE minute(t1.date)
        END as minutes,
        dr.date as origDate,

        CASE
        WHEN snomed.code IS NOT NULL THEN  'Post Op Meds'
        ELSE t1.category
        END as category,

        t1.date as startDate,
        timestampdiff('SQL_TSI_DAY', cast(t1.dateOnly as timestamp), dr.dateOnly) + 1 as daysElapsed,
        t1.enddate, t1.code, t1.volume, t1.vol_units, t1.concentration, t1.conc_units, t1.amountWithUnits,
        t1.amountAndVolume, t1.dosage, t1.dosage_units, t1.frequency.meaning + ' (' + t1.frequency.times + ')' as frequency, t1.route,
        t1.reason, t1.performedby, t1.remark, t1.qcstate.label as TreatmentStatus

        FROM ehr_lookups.dateRange dr

        Join study."Treatment Orders" t1
        ON (dr.dateOnly >= t1.dateOnly and dr.dateOnly <= t1.enddateCoalesced AND
        mod(CAST(timestampdiff('SQL_TSI_DAY', CAST(t1.dateOnly as timestamp), dr.dateOnly) as integer), t1.frequency.intervalindays) = 0
        )

        LEFT JOIN ehr.treatment_times tt ON (tt.treatmentid = t1.objectid)
        LEFT JOIN ehr_lookups.treatment_frequency_times ft ON (ft.frequency = t1.frequency.meaning AND tt.rowid IS NULL)

        INNER JOIN (
        SELECT
        sc.code
        FROM ehr_lookups.snomed_subset_codes sc
        WHERE sc.primaryCategory = 'Post Op Meds'
        /* Added this clause by Kollil on 10/4/2023 to exclude the MPA injection from the list.
         This change is made according to the new request by Cassie Tkt# 9939. The MPA med is part of the post op meds category
         so, excluding the other post op meds from this alert list. This list produces only the MPA injection entires.
         */
        AND sc.code IN ('E-85760')
        GROUP BY sc.code
        ) snomed ON snomed.code = t1.code

--NOTE: if we run this report on a future interval, we want to include those treatments
        WHERE t1.date is not null
--NOTE: they have decided to include non-public data
        ) s

) s ON (s.animalid = h.id)
WHERE h.calculated_status = 'Alive'
  --account for date/time in schedule
  and s.date >= s.startDate and s.date <= s.enddate