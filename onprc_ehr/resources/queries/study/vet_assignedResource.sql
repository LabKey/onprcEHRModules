--Added to 20.11 Process 01-27-2021
SELECT a.Id,
       a.project,
       a.project.use_category,
       a.DATE,
       a.enddate,
       'Resource Assigned' AS ProjectType,
       v.userId AS vetAssignedProject
FROM study.assignment AS a
         JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.onprc_ehr.vet_assignment AS v ON a.project = v.project
WHERE a.DATE <= Now()
  AND (
    a.enddate IS NULL
   OR a.enddate >= Now()
    )
  AND a.project.use_category != 'Research'
