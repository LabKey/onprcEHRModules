SELECT d.Id,
       d.date,
       d.weight,
       d.remark,
       d.description,
       d.taskid,
       d.project,
       d.performedby,
       d.requestid,
       d.Container,
       d.history,
       d.isAssignedAtTime,
       d.isAssignedToProtocolAtTime,
       d.enteredSinceVetReview,
       d.QCState
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.weight d
    where (active = 'y' and s.rh = d.id)