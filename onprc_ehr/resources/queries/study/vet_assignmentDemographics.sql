SELECT nhp.id,
       housing.room,
       housing.room.area,
       demographics.gender,
       demographics.species,
       demographics.calculated_status,
       CMUcase.id AS IDofCase,
       CMUcase.assignedVet.userID AS CaseVet,
       CASE
           WHEN research.project IS NOT NULL
               THEN research.projectType
           WHEN resource.project IS NOT NULL
               THEN resource.projectType
           ELSE NULL
           END AS AssignmentType,
       CASE
           WHEN research.project IS NOT NULL
               THEN research.VetAssignedProject --Update Changed to R from S alias
           WHEN resource.project IS NOT NULL
               THEN resource.VetAssignedProject --Update Changed to R from S alias
           ELSE NULL
           END AS project
       --UPDATE the query needs to display  protocol when appropriate
        ,
       CASE
           WHEN research.project IS NOT NULL
               THEN research.project.protocol.external_id
           WHEN resource.project IS NOT NULL
               THEN resource.project.protocol.external_id
           ELSE NULL
           END AS Protocol
FROM Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.animal nhp
LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.ClinicalCases_Open AS CMUcase ON CMUcase.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.housing housing ON housing.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.demographics demographics ON demographics.id = nhp.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_AssignedResearch research ON nhp.id = research.id
    LEFT JOIN Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vet_assignedResource resource ON nhp.id = resource.id
WHERE demographics.Calculated_Status = 'Alive'
  AND nhp.id NOT LIKE '[A-Z]%'
  AND housing.enddateTimeCoalesced >= now()