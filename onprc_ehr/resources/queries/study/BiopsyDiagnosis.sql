/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select
    a.participantid as Id,
    a.date,
    a.tissue.meaning as "Organ/Tissue",
    a.remark as Diagnosis,
    a.codes as "Snomed Codes",
    a.taskid

From study.histology a, ehr.tasks b
Where a.taskid = b.taskid
  And b.formtype = 'Biopsy'