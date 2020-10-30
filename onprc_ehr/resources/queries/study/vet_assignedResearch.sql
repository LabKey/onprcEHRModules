--20190410 - changed to address no assigned vet for protocol in research update1
--Iss was this was not loaded at the prodctuib level

SELECT distinct a.Id,
                a.project,
                a.project.use_category,
                a.project.protocol,
                a.project.protocol.investigatorID.lastName as PI,
                a.date,
                a.projectedRelease,
                a.enddate,
                a.assignCondition,
                'Research Assigned' as ProtocolType,
                v.protocol.displayName as VetAssignedProtocol
FROM study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.vet_assignment v on a.project.protocol = v.protocol
where (a.project.use_category = 'Research')
  and a.date = CurDate() and a.date = a.enddate
  and v.protocol is not null

Union

SELECT a.Id,
       a.project,
       a.project.use_category,
       a.project.protocol,
       a.project.protocol.investigatorID.lastName as PI,
       a.date,
       a.projectedRelease,
       a.enddate,
       a.assignCondition,
       'Research Assigned' as ProtocolType,
       v.protocol.displayName as VetAssignedProtocol
FROM study.assignment a left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.vet_assignment v on a.project.protocol = v.protocol
where ((a.date <= Now() and a.enddate is null) and (a.project.use_category = 'Research'))
  and v.protocol is not null