/*
study.vetAssignment_filter

Partially replaces: study.demographicsAssignedVet, which still exists

Returns a record for each input record from study.vetAssignment_demographics
using vet assignment rules defined in onprc_ehr.vet_assignment

Notes:
  * This can result in multiple assignments per animal
  * Comparisons against rules check for both matches against rule requirements and
    no additional rule requirements to ensure no false positives
  * Comparisons rely on empty data to be NULL, not ""
  * The code prioritizes research projects over non-research projects *for
    the same rule*
  * Unassigned animals can be found by filtering for "Unassigned" in
    the AssignedVet column
 */

SELECT *
FROM (
         SELECT d.Id,
                CASE
                    WHEN d.CaseVet IS NOT NULL  THEN d.CaseVet
                    WHEN R01.UserID IS NOT NULL THEN R01.UserID.DisplayName
                    WHEN R02.UserID IS NOT NULL THEN R02.UserID.DisplayName
                    WHEN R03.UserID IS NOT NULL THEN R03.UserID.DisplayName
                    WHEN R04.UserID IS NOT NULL THEN R04.UserID.DisplayName
                    WHEN R05.UserID IS NOT NULL THEN R05.UserID.DisplayName
                    WHEN R06.UserID IS NOT NULL THEN R06.UserID.DisplayName
                    WHEN R07.UserID IS NOT NULL THEN R07.UserID.DisplayName
                    WHEN R08.UserID IS NOT NULL THEN R08.UserID.DisplayName
                    WHEN R09.UserID IS NOT NULL THEN R09.UserID.DisplayName
                    WHEN R10.UserID IS NOT NULL THEN R10.UserID.DisplayName
                    WHEN R11.UserID IS NOT NULL THEN R11.UserID.DisplayName
                    WHEN R12.UserID IS NOT NULL THEN R12.UserID.DisplayName
                    WHEN R13.UserID IS NOT NULL THEN R13.UserID.DisplayName
                    WHEN R14.UserID IS NOT NULL THEN R14.UserID.DisplayName
                    WHEN R15.UserID IS NOT NULL THEN R15.UserID.DisplayName
                    WHEN R16.UserID IS NOT NULL THEN R16.UserID.DisplayName
                    WHEN R17.UserID IS NOT NULL THEN R17.UserID.DisplayName
                    WHEN R18.UserID IS NOT NULL THEN R18.UserID.DisplayName
                    WHEN R19.UserID IS NOT NULL THEN R19.UserID.DisplayName
                    WHEN R20.UserID IS NOT NULL THEN R20.UserID.DisplayName
                    WHEN R21.UserID IS NOT NULL THEN R21.UserID.DisplayName
                    WHEN R22.UserID IS NOT NULL THEN R22.UserID.DisplayName
                    ELSE 'Unassigned'
                    END AS AssignedVet,
                CASE
                    WHEN d.CaseVet IS NOT NULL 	THEN 'Open Case'
                    WHEN R01.UserID IS NOT NULL THEN 'Project (Research) Room Priority'
                    WHEN R02.UserID IS NOT NULL THEN 'Project (Resource) Room Priority'
                    WHEN R03.UserID IS NOT NULL THEN 'Project (Research) Area Priority'
                    WHEN R04.UserID IS NOT NULL THEN 'Project (Resource) Area Priority'
                    WHEN R05.UserID IS NOT NULL THEN 'Project (Research) Priority'
                    WHEN R06.UserID IS NOT NULL THEN 'Project (Resource) Priority'
                    WHEN R07.UserID IS NOT NULL THEN 'Protocol Room Priority'
                    WHEN R08.UserID IS NOT NULL THEN 'Protocol Area Priority'
                    WHEN R09.UserID IS NOT NULL THEN 'Protocol Priority'
                    WHEN R10.UserID IS NOT NULL THEN 'Room Priority'
                    WHEN R11.UserID IS NOT NULL THEN 'Area Priority'
                    WHEN R12.UserID IS NOT NULL THEN 'Project (Research) Room'
                    WHEN R13.UserID IS NOT NULL THEN 'Project (Resource) Room'
                    WHEN R14.UserID IS NOT NULL THEN 'Project (Research) Area'
                    WHEN R15.UserID IS NOT NULL THEN 'Project (Resource) Area'
                    WHEN R16.UserID IS NOT NULL THEN 'Project (Research)'
                    WHEN R17.UserID IS NOT NULL THEN 'Project (Resource)'
                    WHEN R18.UserID IS NOT NULL THEN 'Protocol Room'
                    WHEN R19.UserID IS NOT NULL THEN 'Protocol Area'
                    WHEN R20.UserID IS NOT NULL THEN 'Protocol'
                    WHEN R21.UserID IS NOT NULL THEN 'Room'
                    WHEN R22.UserID IS NOT NULL THEN 'Area'
                    ELSE 'No Matching Rule'
                    END AS AssignmentType,
                d.CaseVet,
                d.CaseDate,
                d.Project,
                d.AssignmentType AS ProjectType,
                d.Protocol,
                d.ProtocolPI,
                d.Room,
                d.Area,
                d.Species,
                d.Calculated_status,
                CASE
                    WHEN d.CaseVet IS NOT NULL  THEN 0
                    WHEN R01.UserID IS NOT NULL THEN 1
                    WHEN R02.UserID IS NOT NULL THEN 2
                    WHEN R03.UserID IS NOT NULL THEN 3
                    WHEN R04.UserID IS NOT NULL THEN 4
                    WHEN R05.UserID IS NOT NULL THEN 5
                    WHEN R06.UserID IS NOT NULL THEN 6
                    WHEN R07.UserID IS NOT NULL THEN 7
                    WHEN R08.UserID IS NOT NULL THEN 8
                    WHEN R09.UserID IS NOT NULL THEN 9
                    WHEN R10.UserID IS NOT NULL THEN 10
                    WHEN R11.UserID IS NOT NULL THEN 11
                    WHEN R12.UserID IS NOT NULL THEN 12
                    WHEN R13.UserID IS NOT NULL THEN 13
                    WHEN R14.UserID IS NOT NULL THEN 14
                    WHEN R15.UserID IS NOT NULL THEN 15
                    WHEN R16.UserID IS NOT NULL THEN 16
                    WHEN R17.UserID IS NOT NULL THEN 17
                    WHEN R18.UserID IS NOT NULL THEN 18
                    WHEN R19.UserID IS NOT NULL THEN 19
                    WHEN R20.UserID IS NOT NULL THEN 20
                    WHEN R21.UserID IS NOT NULL THEN 21
                    WHEN R22.UserID IS NOT NULL THEN 22
                    ELSE 99
                    END AS MatchedRule
         FROM study.vetAssignment_demographics AS d

                  /* Priority Rules */
/* R01 Project Research Room Priority */ LEFT JOIN onprc_ehr.vet_assignment R01 ON (R01.Project = d.Project AND R01.Room = d.Room AND R01.Area IS NULL AND R01.Protocol IS NULL AND R01.Priority = TRUE AND d.AssignmentType = 'Research')
/* R02 Project Resource Room Priority */ LEFT JOIN onprc_ehr.vet_assignment R02 ON (R02.Project = d.Project AND R02.Room = d.Room AND R02.Area IS NULL AND R02.Protocol IS NULL AND R02.Priority = TRUE AND d.AssignmentType <> 'Research')
/* R03 Project Area Research Priority */ LEFT JOIN onprc_ehr.vet_assignment R03 ON (R03.Project = d.Project AND R03.Area = d.Area AND R03.Room IS NULL AND R03.Protocol IS NULL AND R03.Priority = TRUE AND d.AssignmentType = 'Research')
/* R04 Project Area Resource Priority */ LEFT JOIN onprc_ehr.vet_assignment R04 ON (R04.Project = d.Project AND R04.Area = d.Area AND R04.Room IS NULL AND R04.Protocol IS NULL AND R04.Priority = TRUE AND d.AssignmentType <> 'Research')
/* R05 Project Research Priority      */ LEFT JOIN onprc_ehr.vet_assignment R05 ON (R05.Project = d.Project AND R05.Area IS NULL AND R05.Room IS NULL AND R05.Protocol IS NULL AND R05.Priority = TRUE AND d.AssignmentType = 'Research')
/* R06 Project Resource Priority      */ LEFT JOIN onprc_ehr.vet_assignment R06 ON (R06.Project = d.Project AND R06.Area IS NULL AND R06.Room IS NULL AND R06.Protocol IS NULL AND R06.Priority = TRUE AND d.AssignmentType <> 'Research')
/* R07 Protocol Room Priority         */ LEFT JOIN onprc_ehr.vet_assignment R07 ON (R07.Protocol.DisplayName = d.Protocol AND R07.Room = d.Room AND R07.Area IS NULL AND R07.Project IS NULL AND R07.Priority = TRUE)
/* R08 Protocol Area Priority         */ LEFT JOIN onprc_ehr.vet_assignment R08 ON (R08.Protocol.DisplayName = d.Protocol AND R08.Area = d.Area AND R08.Room IS NULL AND R08.Project IS NULL AND R08.Priority = TRUE)
/* R09 Protocol Priority              */ LEFT JOIN onprc_ehr.vet_assignment R09 ON (R09.Protocol.DisplayName = d.Protocol AND R09.Area IS NULL AND R09.Room IS NULL AND R09.Project IS NULL AND R09.Priority = TRUE)
/* R10 Room Priority                  */ LEFT JOIN onprc_ehr.vet_assignment R10 ON (R10.Room = d.Room AND R10.Area IS NULL AND R10.Protocol IS NULL AND R10.Project IS NULL AND R10.Priority = TRUE)
/* R11 Area Priority                  */ LEFT JOIN onprc_ehr.vet_assignment R11 ON (R11.Area = d.Area AND R11.Room IS NULL AND R11.Protocol IS NULL AND R11.Project IS NULL AND R11.Priority = TRUE)

             /* Standard Rules */
/* R12 Project Research Room          */ LEFT JOIN onprc_ehr.vet_assignment R12 ON (R12.Project = d.Project AND R12.Room = d.Room AND R12.Area IS NULL AND R12.Protocol IS NULL AND R12.Priority = FALSE AND d.AssignmentType = 'Research')
/* R13 Project Resource Room          */ LEFT JOIN onprc_ehr.vet_assignment R13 ON (R13.Project = d.Project AND R13.Room = d.Room AND R13.Area IS NULL AND R13.Protocol IS NULL AND R13.Priority = FALSE AND d.AssignmentType <> 'Research')
/* R14 Project Research Area          */ LEFT JOIN onprc_ehr.vet_assignment R14 ON (R14.Project = d.Project AND R14.Area = d.Area AND R14.Room IS NULL AND R14.Protocol IS NULL AND R14.Priority = FALSE AND d.AssignmentType = 'Research')
/* R15 Project Resource Area          */ LEFT JOIN onprc_ehr.vet_assignment R15 ON (R15.Project = d.Project AND R15.Area = d.Area AND R15.Room IS NULL AND R15.Protocol IS NULL AND R15.Priority = FALSE AND d.AssignmentType <> 'Research')
/* R16 Project Research               */ LEFT JOIN onprc_ehr.vet_assignment R16 ON (R16.Project = d.Project AND R16.Area IS NULL AND R16.Room IS NULL AND R16.Protocol IS NULL AND R16.Priority = FALSE AND d.AssignmentType = 'Research')
/* R17 Project Resource               */ LEFT JOIN onprc_ehr.vet_assignment R17 ON (R17.Project = d.Project AND R17.Area IS NULL AND R17.Room IS NULL AND R17.Protocol IS NULL AND R17.Priority = FALSE AND d.AssignmentType <> 'Research')
/* R18 Protocol Room                  */ LEFT JOIN onprc_ehr.vet_assignment R18 ON (R18.Protocol.DisplayName = d.Protocol AND R18.Room = d.Room AND R18.Area IS NULL AND R18.Project IS NULL AND R18.Priority = FALSE)
/* R19 Protocol Area                  */ LEFT JOIN onprc_ehr.vet_assignment R19 ON (R19.Protocol.DisplayName = d.Protocol AND R19.Area = d.Area AND R19.Room IS NULL AND R19.Project IS NULL AND R19.Priority = FALSE)
/* R20 Protocol                       */ LEFT JOIN onprc_ehr.vet_assignment R20 ON (R20.Protocol.DisplayName = d.Protocol AND R20.Area IS NULL AND R20.Room IS NULL AND R20.Project IS NULL AND R20.Priority = FALSE)
/* R21 Room                           */ LEFT JOIN onprc_ehr.vet_assignment R21 ON (R21.Room = d.Room AND R21.Area IS NULL AND R21.Protocol IS NULL AND R21.Project IS NULL AND R21.Priority = FALSE)
/* R22 Area                           */ LEFT JOIN onprc_ehr.vet_assignment R22 ON (R22.Area = d.Area AND R22.Room IS NULL AND R22.Protocol IS NULL AND R22.Project IS NULL AND R22.Priority = FALSE)
     ) AS placeholderAlias
