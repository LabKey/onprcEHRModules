--Author: Jonesga with Kollil as Sidekick



-- Modified Date 7/5/2023



-- Create date: 2020



-- - Description: Application is designed to assign a vet to a room, area, project, protocol, or case.



-- -----This query is designed to show the assignment of the vet to the room, area, project, protocol, or case.



-- Deploy to Test1 for Validation



-- =============================================





SELECT



    Distinct
    Case
        when dm.Id is not null then dm.id
        else d.id
        end as id,
    b.gender,
    b.species,
    b.geographic_origin,
    b.date,
    dm.death as death,
    dm.LastDayAtCenter,
    h.room.area as area,
    h.room,
    Case
        when dm.id is not null then dm.calculated_status
        End
        As Calculated_status,
    c.vetNames as CaseVet,
    c.category,
    CASE
        WHEN (c.id IS NOT NULL) THEN 'Active Case'
        when s1.project is not null then s1.projectType
        when s2.project is not null then s2.projectType
        ELSE 'unassigned'
        END as assignmentType,
    Case
        when s1.project is not null then s1.use_category
        when s2.project is not null then s2.use_category
        else null
        End As use_category,
    Case
        when s1.project is not null then s1.project.protocol.displayname
        when s2.project is not null then s2.project.Protocol.displayname
        else null
        End As protocol,
    Case
        when s1.project is not null then s1.project
        when s2.project is not null then s2.project
        else null
        End As project,
    Case
        when s1.project is not null then s1.PI
        when s2.project is not null then s2.PI
        else null
        End As ProtocolPI,
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.animal d



--Handles NHPS with open Cases





LEFT JOIN (



SELECT



c.Id,



c.category,



c.assignedvet.DisplayName as vetNames,



c.date





FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.cases c



WHERE c.category not in ('Behavior','Surgery')



and c.IsOpen= 'true'



GROUP BY c.Id,c.category,c.date,c.assignedvet.DisplayName)



c ON c.Id = d.Id



    -- // This query is creting duplication on the Protocol need to address the issue



-- LEFT JOIN (



-- SELECT



-- a1.Id,



-- a1.project.protocol as protocol,



-- a1.project.protocol.investigatorID.lastName as ProtocolPI,



-- a1.project.use_category



--



-- FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.Assignment a1,



-- Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.vet_assignment v1



-- where a1.enddate is null and v1.protocol = a1.project.protocol



-- and a1.project.use_category in



-- (Select use_category,



-- Case when s1.project is not null then s1.use_category



-- when s2.project is not null then s2.use_category



-- else null



-- End As use_category)



-- -- GROUP BY a1.Id,a1.project.protocol,a1.project.protocol.investigatorID.lastName )



-- a1 ON a1.Id = d.Id



--Review for Assigned Animals



    left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.birth b on b.id = d.id



    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_assignedResource r2 on d.id = r2.id --and r2.id not in (Select r3.id from study.vet_AssignedResearch r3)*/



    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_AssignedResearch_project s1 on d.id = s1.id



    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.vet_assignedResource_project s2 on d.id = s2.id



    Left Join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.housing h on h.id = d.id and (h.enddateTimeCoalesced >= now())



    left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.demographics dm on dm.id = d.id



    left join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.clinRemarks cr on cr.id = d.id





where



    (d.demographics.calculated_status = 'alive')