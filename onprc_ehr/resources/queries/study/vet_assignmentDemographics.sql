SELECT d.id
     ,h.room
     ,h.room.area
     ,dm.gender
     ,dm.species
     ,dm.calculated_status
     --,r1.id as ResearchAssigned
  --   ,r1.use_category
   --  ,r2.useCatgegory2
     --,r2.id as ResourceAssigned
     ,co.id AS IDofCase
     ,co.assignedVet as CaseVet
     ,Case
        when r1.project is not null then r1.projectType
        when r2.project is not null then r2.projectType
        Else Null
    End as AssignmentType,
    Case
        when r1.project is not null then r1.VetAssignedProject --Update Changed to R from S alias
        when r2.project is not null then r2.VetAssignedProject  --Update Changed to R from S alias
        else  null
        End As project
--UPDATE the query needs to display  protocol when appropriate
    ,Case
    When r1.project is not null then r1.project.protocol.external_id
      When r2.project is not null then r2.project.protocol.external_id
    else Null
    End as Protocol
FROM Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.animal d
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.ClinicalCases_Open AS co ON co.id = d.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.housing h ON h.id = d.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.demographics dm ON dm.id = d.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_AssignedResearch r1 ON d.id = r1.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_assignedResource r2 ON d.id = r2.id
WHERE dm.Calculated_Status = 'Alive'
  AND d.id NOT LIKE '[A-Z]%'
  AND h.enddateTimeCoalesced >= now()