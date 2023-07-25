--20190410 - changed to address no assigned vet for protocol in research update1
--Iss was this was not loaded at the prodctuib level
--2021-01-27added to 20.11 process

SELECT a.Id,
       a.project,
       a.project.use_category,
       a.DATE,
       a.enddate,
       'Research Assigned' AS ProjectType,
       v.userId.displayName AS vetAssignedProject
FROM study.assignment AS a
         JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.onprc_ehr.vet_assignment AS v ON a.project = v.project
WHERE a.DATE <= Now()
  AND (
    a.enddate IS NULL
   OR a.enddate >= Now()
    )
  AND a.project.use_category = 'Research'
