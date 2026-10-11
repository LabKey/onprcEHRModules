/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT d.Id,
       d.date,
       d.project,
       d.chargetype,
       d.reason,
       d.tube_type,
       d.tube_vol,
       d.num_tubes,
       d.quantity,
       d.additionalServices,
       d.instructions,
       d.sampletype,
       d.performedby,
       d.remark,
       d.description,
       d.requestid,
       d.taskid,
       d.Container,
       d.countsAgainstVolume,
       d.history,
       d.isAssignedAtTime,
       d.isAssignedToProtocolAtTime,
       d.enteredSinceVetReview,
       d.QCState
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.blood d
    where (active = 'y' and s.rh = d.id)