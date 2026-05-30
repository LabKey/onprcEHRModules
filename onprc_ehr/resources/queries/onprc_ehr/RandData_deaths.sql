/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
d.Id,
d.date,
d.cause,
d.necropsy,
d.remark,
d.cageattime,
d.dam,
d.performedby,
d.roomattime,
d.notAtCenter,
d.description,
d.taskid,
d.project,
d.requestid,
d.Container,
d.history,
d.isAssignedAtTime,
d.isAssignedToProtocolAtTime,
d.enteredSinceVetReview,
d.QCState
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.deaths d
    where (active = 'y' and s.rh = d.id)