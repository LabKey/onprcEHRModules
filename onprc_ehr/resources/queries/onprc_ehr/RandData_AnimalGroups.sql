SELECT d.Id,
       d.date,
       d.enddate,
       d.groupId,
       d.releaseType,
       d.qcstate,
       d.remark,
       d.performedby,
       d.taskid,
       d.requestid,
       d.description,
       d.Container,
       d.isActive,
       d.history,
       d.isAssignedAtTime,
       d.isAssignedToProtocolAtTime,
       d.enteredSinceVetReview
 FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.animal_group_members d

    where (s.rh = d.id)