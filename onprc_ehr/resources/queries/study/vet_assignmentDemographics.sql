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
        When r1.id is not null then r1.assignedProjectType
        When r2.id is not null then r2.assignedProjectType
        Else 'P51'
        End as assignmentType,

    Case
        When r1.protocol is not null then r1.assignedProjectType
        When r2.protocol is not null then r2.assignedProjectType
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

    -- Get Data for Protocol Assignment and PI
         Left Join study.vet_assignedProject r1 on dm.id = r1.id and r1.assignedProjectType = 'Research Project'
         Left Join study.vet_assignedProject r2 on dm.id = r2.id and r2.assignedProjectType = 'Resource Project'

-- Get only live animals
Where dm.calculated_status = 'Alive' And dm.Id not like '[A-Z]%'