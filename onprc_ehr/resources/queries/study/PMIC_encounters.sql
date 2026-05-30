/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    requestid,
    Id,
    date,
    id.activeAssignments.projects as ActiveAssignments,
    project,
    project.investigatorid,
    chargeType,
    procedureid,
    remark,
    QCState,
    taskid
--     requestid.createdby
--     isAssignedToProtocolAtTime
from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.encounters
Where chargeType like 'PMIC'