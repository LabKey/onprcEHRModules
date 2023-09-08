--Modified by Kollil, 8/31/23
Select
    a.Id,
    a.project,
    a.project.protocol.external_id as Protocol,
    a.project.protocol.investigatorID.lastName as PI,
    a.project.use_category,
    a.date,
    a.projectedRelease,
    a.enddate,
    a.assignCondition,
    Case
        When (a.project.use_category = 'Research') Then 'Project Research Assigned'
        Else 'Project Resource Assigned'
    End as ProjectType
From study.assignment a
Where (a.date <= Now() And (a.enddate IS NULL OR a.enddate >= Now())) OR (a.date = Now() And a.date = a.enddate)