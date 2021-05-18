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
    taskid,
    requestid.createdby,
    taskid
--     isAssignedToProtocolAtTime
from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.encounters
Where chargeType like 'PMIC'