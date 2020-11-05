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
    CASE
        --if enddate is null and start date is before the current date - list current room & cage
        WHEN endDate IS NULL AND Date <= curDate() THEN Id.curLocation.room
        --if endate is null and start date is a future date - do not list room & cage
        WHEN endDate IS NULL AND Date >= curDate() THEN NULL
        --if enddate is before the current date - list room & cage at time of enddate
        WHEN endDate <= curDate() AND Date <= curDate() THEN (Select h.room From housing h
                                                              Where (h.Id = Id) And (h.date <= endDate and h.enddateCoalesced >= endDate) ORDER BY h.date DESC LIMIT 1)
        --if enddate is a future date and start date is before the current date - list current room & cage
        WHEN endDate >= curDate() AND Date <= curDate() THEN Id.curLocation.room
        ELSE NULL
        END AS Room,
    CASE
        --if enddate is null and start date is before the current date - list current room & cage
        WHEN endDate IS NULL AND Date <= curDate() THEN Id.curLocation.cage
        --if endate is null and start date is a future date - do not list room & cage
        WHEN endDate IS NULL AND Date >= curDate() THEN NULL
        --if enddate is before the current date - list room & cage at time of enddate
        WHEN endDate <= curDate() AND Date <= curDate() THEN (Select h.cage From housing h
                                                              Where (h.Id = Id) And (h.date <= endDate and h.enddateCoalesced >= endDate) ORDER BY h.date DESC LIMIT 1)
                                                                --(h.Id = Id And h.enddate IS NULL)
                                                                --OR (h.Id = Id And h.enddate IS NOT NULL And (endDate between h.date and h.enddate))
        --if enddate is a future date and start date is before the current date - list current room & cage
        WHEN endDate >= curDate() AND Date <= curDate() THEN Id.curLocation.cage
        ELSE NULL
        END AS Cage,
    taskid
From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.StudyDetails