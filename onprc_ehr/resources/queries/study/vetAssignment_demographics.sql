/*
study.vetAssignment_demographics

Replaces: study.vetAssignmentDemographics

Returns at least one record for all living NHPs at the center.
Notes:
  * Multiple open cases and multiple assignments for a single animal
    result in open cases * assignments for that animal
  * Left joins are needed for CMUcases and assignedProject as those tables
    might not have records for an animal ID. Left joins are used for all
	other joins to be resilient against missing data.

Future potential modifications:
  * Limit open cases to those that are not inactive	after confirming w/ Heather
 */

SELECT demographics.id
     , CMUcases.assignedVet.displayName AS caseVet
     , CMUcases.date AS caseDate
     , housing.room
     , housing.room.area
     , assignedProject.project AS project
     , assignedProject.Protocol AS protocol
     , assignedProject.PI AS protocolPI
     , assignedProject.projectType AS assignmentType
     , demographics.calculated_status
     , demographics.gender
     , demographics.species
     , demographics.history
FROM Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.animal AS nhp
LEFT JOIN Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.ClinicalCases_Open AS CMUcases
ON CMUcases.id = nhp.id
    LEFT JOIN Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.housing AS housing
    ON housing.id = nhp.id
    LEFT JOIN Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.demographics AS demographics
    ON demographics.id = nhp.id
    LEFT JOIN Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.vetAssignment_projects AS assignedProject
    ON assignedProject.id = nhp.id
WHERE demographics.Calculated_Status = 'Alive'
  AND nhp.id NOT LIKE '[A-Z]%'
  AND housing.enddate IS NULL
