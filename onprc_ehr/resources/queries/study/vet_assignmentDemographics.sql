/*Update 2023/08/31*/
SELECT
    Distinct
    dm.Id,
    dm.gender,
    dm.species,
    dm.geographic_origin,
    dm.date,
    dm.death as death,
    dm.LastDayAtCenter,
    h.room.area,
    h.room,
    dm.calculated_status,
    c.vetNames as CaseVet,
    c.category,



    Case
        When (c.id IS NOT NULL) then 'Active Case'
         When r1.id is not null then r1.projecttype
        When r2.id is not null then r2.projecttype
        Else ''
        End as assignmentType,



    Case

        When r1.project is not null then r1.use_Category
        When r2.project is not null then r2.use_category
        Else ''
        End As use_category,



    Case
        When r1.protocol is not null then r1.Protocol
        When r2.protocol is not null then r2.Protocol
        Else ''
        End As protocol,



    Case
        When r1.project is not null then r1.project
        When r2.project is not null then r2.project
        Else null
        End As project,

    Case
        When r1.project is not null then r1.project.displayName
        When r2.project is not null then r2.project.displayName
        Else null
        End As projectName,

    Case
        When r1.protocol is not null then r1.PI
        When r2.protocol is not null then r2.PI
        Else ''
        End As ProtocolPI



FROM study.demographics dm



         --Handles animlas with open Cases
         LEFT Join (
    Select
        c.Id,
        c.category,
        c.assignedvet.DisplayName as vetNames,
        c.date
    From study.cases c
    Where (c.category not in ('Behavior','Surgery') And c.IsOpen= 'true')
    GROUP BY c.Id, c.category, c.date, c.assignedvet.DisplayName
) c ON (c.Id = dm.Id)



    --Get housing data
         Left Join study.housing h on h.id  = dm.id and (h.enddateTimeCoalesced >= now())



    -- Get from Vet data
         Left Join study.vet_assignmentResearchandResource_Project r1 on dm.id = r1.id and r1.projecttype = 'Project Research Assigned'
         Left Join vet_assignmentResearchandResource_Project r2 on dm.id = r2.id and r2.projecttype != 'Project Research Assigned'




--Get only live animals
Where dm.calculated_status = 'Alive' And dm.Id not like '[A-Z]%'

