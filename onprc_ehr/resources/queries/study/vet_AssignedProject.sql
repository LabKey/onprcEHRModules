/*Update20230830*/
SELECT a.Id,
       a.project,
       a.project.protocol.external_id as Protocol,
       a.project.protocol.investigatorID as PI,
       a.DATE,
       a.enddate,
       a.project.use_category as ProtoclType,
       CASE
           WHEN a.project.use_category = 'Research'
               THEN 'Research Project'
           ELSE 'Resource Project'
           END AS assignedProjectType
FROM study.assignment AS a
WHERE a.DATE <= Now()
  AND (
        a.enddate IS NULL
        OR a.enddate >= Now())