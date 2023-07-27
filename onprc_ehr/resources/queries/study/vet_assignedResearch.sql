SELECT a.Id,
       a.project,
       a.project.use_category,
       a.DATE,
       a.enddate,
       'Research Assigned' AS ProjectType,
       v.userID AS vetAssignedProject
FROM study.assignment AS a
         JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.onprc_ehr.vet_assignment AS v ON a.project = v.project
WHERE a.DATE <= Now()
  AND (
    a.enddate IS NULL
   OR a.enddate >= Now()
    )
  AND a.project.use_category = 'Research'
