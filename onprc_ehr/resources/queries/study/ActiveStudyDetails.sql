Select
    Id,
    project, project.protocol, project.protocol.investigatorId,
    Date StartDate, endDate,
    studyCohort,
    studyGroup,
    studyGroupNum,
    studyPhase,
    remark,
    performedby,
    Id.demographics.calculated_status,
    Id.demographics.gender,
    Id.curLocation.room,
    Id.curLocation.cage,
    taskid
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.StudyDetails
Where (curdate() between Date and endDate) OR ( (curdate() >= Date) and (endDate IS NULL))




