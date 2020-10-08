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
FROM study.assignment a left outer join "/onprc/ehr".onprc_ehr.vet_assignment v on a.project.protocol = v.protocol
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
FROM study.assignment a left outer join "/onprc/ehr".onprc_ehr.vet_assignment v on a.project.protocol = v.protocol
where (a.project.use_category != 'Research')
  and a.date = CurDate() and a.date = a.enddate
  and v.protocol is not null
