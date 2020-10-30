SELECT a.Id,
       a.project,
       a.dateOnly,
       a.endDateCoalesced
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a
where a.enddate is Null and a.project.use_category like '%obese%'