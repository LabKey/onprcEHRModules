/*
 * Copyright (c) 2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
select a.Id,
       a.date,
       a.servicerequested,
       b.testid,
       b.qualresult,
       a.vet,
       a.created,
       b.objectid,
       b.runid,
      (select j.rowid from ehr.tasks j where j.taskid = a.taskid) as taskid,
      a.type


from study.ClinpathRuns a, study.chemistryResults b
Where  a.objectid = b.runid
  And a.type = 'biochemistry'
  And b.qualresult like '%alert%'

  And a.qcstate = 18
  And b.qcstate = 18