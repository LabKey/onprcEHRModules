/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT d.Id,
        d.project,
        d.date,
        d.projectedRelease,
        d.enddate,
        d.assignmentType,
        d.assignCondition,
        d.projectedReleaseCondition,
        d.releaseCondition,
        d.releaseType,
        d.remark,
        d.description,
        d.taskid,
        d.requestid,
        d.Container,
        d.isActive,
        d.history,
        d.enteredSinceVetReview,
        d.QCState
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment d
    where (active = 'y' and s.rh = d.id)