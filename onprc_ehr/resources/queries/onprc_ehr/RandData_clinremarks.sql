SELECT d.Id,
       d.project,
       d.date,
       d.hx,
       d.s,
       d.o,
       d.a,
       d.p,
       d.p2,
       d.remark,
       d.performedby,
       d.description,
       d.taskid,
       d.requestid,
       d.CEG_Plan,
       d.assignedVet,
       d.Container,
       d.history,
       d.isAssignedAtTime,
       d.isAssignedToProtocolAtTime,
       d.enteredSinceVetReview,
       d.QCState
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.clinRemarks d
    where (active = 'y' and s.rh = d.id)