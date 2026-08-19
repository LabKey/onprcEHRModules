/*
study.vetAssignment_demographics

Returns at least one record for all living NHPs at the center.
Notes:
  * Multiple open cases and multiple assignments for a single animal
    result in open cases * assignments for that animal
 */

WITH CasesData AS (
    SELECT Id,
        Open_CMU_Cases.AssignedVet.DisplayName AS CaseVet,
        Open_CMU_Cases.Date AS CaseDate,
        GROUP_CONCAT(ProblemCategories, ';') AS ActiveMasterProblems
    FROM Study.ClinicalCases_Open AS Open_CMU_Cases
    GROUP BY Open_CMU_Cases.AssignedVet.DisplayName, Id, Open_CMU_Cases.Date
)
SELECT
    Demographics.Id,
    CasesData.CaseVet,
    CasesData.CaseDate,
    CasesData.ActiveMasterProblems,
    Housing.Room,
    Housing.Room.Area,
    AssignedProject.Project AS Project,
    AssignedProject.Protocol AS Protocol,
    AssignedProject.PI AS ProtocolPI,
    AssignedProject.ProjectType AS AssignmentType,
    Demographics.Calculated_Status,
    Demographics.Gender,
    Demographics.Species,
    Demographics.History
FROM Study.Demographics AS Demographics
LEFT JOIN CasesData ON Demographics.Id = CasesData.Id
LEFT JOIN Study.Housing AS Housing ON Demographics.Id = Housing.Id
LEFT JOIN Study.VetAssignment_projects AS AssignedProject ON Demographics.Id = AssignedProject.Id
WHERE Demographics.Calculated_Status = 'Alive'
    AND NOT (LOWER(LEFT(Demographics.Id,1)) BETWEEN 'a' AND 'z')
    AND Housing.Enddate IS NULL