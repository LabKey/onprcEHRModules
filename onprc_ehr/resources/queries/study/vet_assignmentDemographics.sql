SELECT nhp.id
     ,housing.room
     ,housing.room.area
     ,demographics.gender
     ,demographics.species
     ,demographics.calculated_status
     --,r1.id as ResearchAssigned
  --   ,r1.use_category
   --  ,r2.useCatgegory2
     --,r2.id as ResourceAssigned
     ,CMUcase.id AS IDofCase
     ,CMUcase.assignedVet.userID as CaseVet
     ,Case
        when research.project is not null then research.projectType
        when resource.project is not null then resource.projectType
        Else Null
    End as AssignmentType,
    Case
        when research.project is not null then research.VetAssignedProject --Update Changed to R from S alias
        when resource.project is not null then resource.VetAssignedProject  --Update Changed to R from S alias
        else  null
        End As project
--UPDATE the query needs to display  protocol when appropriate
    ,Case
    When research.project is not null then research.project.protocol.external_id
      When resource.project is not null then resource.project.protocol.external_id
    else Null
    End as Protocol
FROM Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.animal nhp
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.ClinicalCases_Open AS CMUcase ON CMUcase.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.housing housing ON housing.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.demographics demographics ON demographics.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_AssignedResearch research ON nhp.id = research.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_assignedResource resource ON nhp.id = resource.id
WHERE demographics.Calculated_Status = 'Alive'
  AND nhp.id NOT LIKE '[A-Z]%'
  AND housing.enddateTimeCoalesced >= now()