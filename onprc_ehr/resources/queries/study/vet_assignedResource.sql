--Added to 20.11 Process 01-27-2021
--update to handle project


SELECT a.Id,
       a.project,
       a.project.use_category,
       a.project.protocol,
       a.project.protocol.investigatorID.lastName as PI,
       a.date,
       a.projectedRelease,
       a.enddate,
       a.assignCondition,
       'Resource Assigned' as ProtocolType,
       v.protocol.displayName as VetAssignedProtocol
FROM study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.vet_assignment v on a.project = v.project
where ((a.date <= Now() and a.enddate is null) and (a.project.use_category != 'Research'))

UNION

SELECT  a.Id,
        a.project,
        a.project.use_category,
        a.project.protocol,
        a.project.protocol.investigatorID.lastName as PI,
        a.date,
        a.projectedRelease,
        a.enddate,
        a.assignCondition,
        'Resource Assigned' as ProtocolType,
        v.protocol.displayName as VetAssignedProtocol
FROM study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.vet_assignment v on a.project = v.project
where (a.project.use_category != 'Research')
  and a.date = CurDate() and a.date = a.enddate
  and v.protocol is not null