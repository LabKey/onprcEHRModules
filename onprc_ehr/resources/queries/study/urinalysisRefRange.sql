/*
 * Copyright (c) 2010-2017 LabKey Corporation
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
c.AgeAtTime,
ac.ageClass,

c.taskid,
c.qcstate

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
    c.taskid,
    c.qcstate,
    c.id,
    c.date,
    ROUND(CONVERT(age_in_months(c.id.dataset.demographics.birth, c.date), DOUBLE) / 12.0, 1) as ageAtTime
    FROM "Urinalysis Results" c
    WHERE c.qcstate.publicdata = true AND result is not null

) c

 JOIN ehr_lookups.ageclass ac  ON (
 ( c.ageAtTime >= ac."min" AND
  (c.ageAtTime < ac."max" OR ac."max" is null) ) AND
  c.species = ac.species
 and ac.gender in (select x.gender from demographics x where id = c.id)

)