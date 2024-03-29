/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT

c.lsid,
c.id,
c.date,
c.gender,
c.species,
c.testId,
c.alertOnAbnormal,
c.alertOnAny,
c.result,
c.resultOORIndicator,
c.units,
c.qualresult,
c.AgeAtTime,
--ac.ageClass,
r.ref_range_min,
r.ref_range_max,
cast(round(convert(r.ref_range_min, double), 2) as varchar) || '-' || cast(round(convert(r.ref_range_max, double), 2) as varchar) as range,
CASE
  WHEN c.result >= r.ref_range_min AND c.result <= r.ref_range_max
    THEN 'Normal'
  WHEN c.result < r.ref_range_min
    THEN 'Low'
  WHEN c.result > r.ref_range_max
    THEN 'High'
END as status,
c.remark,
c.taskid,
c.runId,
c.qcstate,
 r.type

FROM (
    SELECT
    c.lsid,
    c.id.dataset.demographics.gender as gender,
    c.id.dataset.demographics.species as species,
    c.testId,
    c.testid.alertOnAbnormal as alertOnAbnormal,
    c.testid.alertOnAny as alertOnAny,
    c.result,
    c.resultOORIndicator,
    c.units,
    c.qualresult,
    c.taskid,
    c.qcstate,
    c.id,
    c.date,
    c.runId,
    c.remark,
    c.type,
    ROUND(CONVERT(age_in_months(c.id.dataset.demographics.birth, c.date), DOUBLE) / 12.0, 1) as ageAtTime
    FROM "Chemistry Results" c
    WHERE c.qcstate.publicdata = true
) c

-- LEFT JOIN ehr_lookups.ageclass ac ON (
--   c.ageAtTime >= ac."min" AND
--   (c.ageAtTime < ac."max" OR ac."max" is null) AND
--   c.species = ac.species
-- )

LEFT JOIN ehr_lookups.lab_test_range r ON (
  c.testId = r.test AND
  (c.species = r.species or (c.species is not null and r.species is null)) AND
  --(ac.ageClass = r.age_class OR (ac.ageClass IS NULL AND r.age_class IS NULL)) AND
  (c.gender = r.gender or (c.gender is not null and r.gender is null))  and
  coalesce(c.type,'Biochemistry') = r.type
)

