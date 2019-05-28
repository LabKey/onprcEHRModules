/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

 --NOTE: this is joined to demographics such that animals never tested for TB
 --will still get a value for MonthsSinceLastTB
select
  d.Id,
  T2.lastDate as MostRecentTBDate,
  case
    WHEN T2.lastDate IS NULL THEN null
    ELSE age_in_months(T2.lastDate, now())
  END AS MonthsSinceLastTB,
  case
    WHEN T2.lastDate IS NULL THEN 6
    ELSE (6 - age_in_months(T2.lastDate, now()))
  END AS MonthsUntilDue,

  (SELECT group_concat(DISTINCT f.flag.value) FROM study.flags f WHERE f.id = d.id AND (f.flag.value IN ('Do Not TB Test', 'TB Serologic test only')) AND f.isActive = true) as flags,
  d.calculated_status
from study.demographics d

LEFT JOIN (select id, max(date) as lastDate from study.encounters e WHERE e.qcstate.publicdata = true AND e.procedureid.name IN (javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TB_TEST_INTRADERMAL'), javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TB_TEST_SEROLOGIC')) group by id) T2
ON (d.id = t2.id)





