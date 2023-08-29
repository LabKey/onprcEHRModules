SELECT a.Id,
       a.project,
       a.project.protocol.external_id,
       a.project.protocol.investigatorID,
       a.DATE,
       a.enddate,
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