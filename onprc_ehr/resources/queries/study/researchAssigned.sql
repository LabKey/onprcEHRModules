SELECT assignment.Id,
--assignment.project,
Max(assignment.project.protocol) as protocol,
--assignment.Cohort,
--assignment.date,
--assignment.enddate,
--assignment.project.use_category,
v.userId.displayName as vetAssigned
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.Vet_Assignment v on assignment.project.protocol = v.protocol.protocol
where project.use_category = 'research' and enddate is null
group by assignment.Id,v.userId.displayName