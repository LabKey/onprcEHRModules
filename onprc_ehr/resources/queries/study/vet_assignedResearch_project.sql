--update jonesga  1-28-2021
--added to 20.11 to handle project assignment for Resource Projects

--updated by Kollil, June 28th
Select a.Id,
       a.project,
       a.project.project as ProjectID,
       v.project.project as VetAssignedProject,
       a.project.protocol.investigatorID.lastName as PI,
       a.project.use_category,
       v.userid.userid,
       a.date,
       a.projectedRelease,
       a.enddate,
       a.assignCondition,
       CASE
           when v.project is not null then 'Project Research Assigned'
           End as ProjectType
From onprc_ehr.vet_assignment v left outer join  study.assignment a on a.project.project = v.project.project
Where (v.project is not null and (a.date <= Now() and a.enddate is null) and a.project.use_category = 'Research')
