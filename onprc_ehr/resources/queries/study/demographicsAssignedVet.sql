SELECT *
FROM ( SELECT DISTINCT d.Id,
                       d.Area,
                       d.Room,
                       d.CaseVet,
                       d.Project,
                       d.AssignmentType AS CodeAssignmentType,
                       d.Calculated_status,
                       d.CaseVet,
                       CASE
                           WHEN d.CaseVet  IS NOT NULL THEN d.CaseVet.displayName
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
                           ELSE 'unassigned'
                           END AS AssignedVet,
                       CASE
                           WHEN d.CaseVet  IS NOT NULL THEN 'Open Case'
                           WHEN R01.UserID IS NOT NULL THEN 'Room Priority'
                           WHEN R02.UserID IS NOT NULL THEN 'Area Priority'
                           WHEN R03.UserID IS NOT NULL THEN 'Project Room Research Priority'
                           WHEN R04.UserID IS NOT NULL THEN 'Project Room Resource Priority'
                           WHEN R05.UserID IS NOT NULL THEN 'Project Room Research'
                           WHEN R06.UserID IS NOT NULL THEN 'Project Room Resource'
                           WHEN R07.UserID IS NOT NULL THEN 'Project Area Research Priority'
                           WHEN R08.UserID IS NOT NULL THEN 'Project Area Resource Priority'
                           WHEN R09.UserID IS NOT NULL THEN 'Project Area Research'
                           WHEN R10.UserID IS NOT NULL THEN 'Project Area Resource'
                           WHEN R11.UserID IS NOT NULL THEN 'Project Research Priority'
                           WHEN R12.UserID IS NOT NULL THEN 'Project Resource Priority'
                           WHEN R13.UserID IS NOT NULL THEN 'Project Research'
                           WHEN R14.UserID IS NOT NULL THEN 'Project Resource'
                           WHEN R15.UserID IS NOT NULL THEN 'Protocol Room Priority'
                           WHEN R16.UserID IS NOT NULL THEN 'Protocol Area Priority'
                           WHEN R17.UserID IS NOT NULL THEN 'Protocol Room'
                           WHEN R18.UserID IS NOT NULL THEN 'Protocol Area'
                           WHEN R19.UserID IS NOT NULL THEN 'Protocol Priority'
                           WHEN R20.UserID IS NOT NULL THEN 'Protocol'
                           WHEN R21.UserID IS NOT NULL THEN 'Room'
                           WHEN R22.UserID IS NOT NULL THEN 'Area'
                           ELSE 'No Matching Rule'
                           END AS AssignmentType

       FROM study.vet_assignmentDemographics d

/* R01 Room Priority                     */ LEFT JOIN onprc_ehr.vet_assignment R01 ON (R01.Room = d.Room AND R01.Area IS NULL AND R01.Project IS NULL AND R01.Protocol IS NULL AND R01.Priority = true)
/* R02 Area Priority                     */ LEFT JOIN onprc_ehr.vet_assignment R02 ON (R02.Area = d.Area AND R02.Room IS NULL AND R02.Project IS NULL AND R02.Protocol IS NULL AND R02.Priority = true)

/* R03 Project Room Research Priority    */ LEFT JOIN onprc_ehr.vet_assignment R03 ON (R03.Project = d.Project AND R03.Room = d.Room AND R03.Area IS NULL AND R03.Protocol IS NULL AND R03.Priority = true  AND d.AssignmentType = 'Project Research Assigned')
/* R04 Project Room Resource Priority    */ LEFT JOIN onprc_ehr.vet_assignment R04 ON (R04.Project = d.Project AND R04.Room = d.Room AND R04.Area IS NULL AND R04.Protocol IS NULL AND R04.Priority = true  AND d.AssignmentType = 'Project Resource Assigned')

/* R05 Project Room Research             */ LEFT JOIN onprc_ehr.vet_assignment R05 ON (R05.Project = d.Project AND R05.Room = d.Room AND R05.Area IS NULL AND R05.Protocol IS NULL AND R05.Priority = false AND d.AssignmentType = 'Project Research Assigned')
/* R06 Project Room Resource             */ LEFT JOIN onprc_ehr.vet_assignment R06 ON (R06.Project = d.Project AND R06.Room = d.Room AND R06.Area IS NULL AND R06.Protocol IS NULL AND R06.Priority = false AND d.AssignmentType = 'Project Resource Assigned')

/* R07 Project Area Research Priority    */ LEFT JOIN onprc_ehr.vet_assignment R07 ON (R07.Project = d.Project AND R07.Area = d.Area AND R07.Room IS NULL AND R07.Protocol IS NULL AND R07.Priority = true  AND d.AssignmentType = 'Project Research Assigned')
/* R08 Project Area Resource Priority    */ LEFT JOIN onprc_ehr.vet_assignment R08 ON (R08.Project = d.Project AND R08.Area = d.Area AND R08.Room IS NULL AND R08.Protocol IS NULL AND R08.Priority = true  AND d.AssignmentType = 'Project Resource Assigned')

/* R09 Project Area Research             */ LEFT JOIN onprc_ehr.vet_assignment R09 ON (R09.Project = d.Project AND R09.Area = d.Area AND R09.Room IS NULL AND R09.Protocol IS NULL AND R09.Priority = false AND d.AssignmentType = 'Project Research Assigned')
/* R10 Project Area Resource             */ LEFT JOIN onprc_ehr.vet_assignment R10 ON (R10.Project = d.Project AND R10.Area = d.Area AND R10.Room IS NULL AND R10.Protocol IS NULL AND R10.Priority = false AND d.AssignmentType = 'Project Resource Assigned')

/* R11 Project Research Priority         */ LEFT JOIN onprc_ehr.vet_assignment R11 ON (R11.Project = d.Project AND R11.Area IS NULL  AND R11.Room IS NULL AND R11.Protocol IS NULL AND R11.Priority = true  AND d.AssignmentType = 'Project Research Assigned')
/* R12 Project Resource Priority         */ LEFT JOIN onprc_ehr.vet_assignment R12 ON (R12.Project = d.Project AND R12.Area IS NULL  AND R12.Room IS NULL AND R12.Protocol IS NULL AND R12.Priority = true  AND d.AssignmentType = 'Project Resource Assigned')

/* R13 Project Research                  */ LEFT JOIN onprc_ehr.vet_assignment R13 ON (R13.Project = d.Project AND R13.Area IS NULL  AND R13.Room IS NULL AND R13.Protocol IS NULL AND R13.Priority = false AND d.AssignmentType = 'Project Research Assigned')
/* R14 Project Resource                  */ LEFT JOIN onprc_ehr.vet_assignment R14 ON (R14.Project = d.Project AND R14.Area IS NULL  AND R14.Room IS NULL AND R14.Protocol IS NULL AND R14.Priority = false AND d.AssignmentType = 'Project Resource Assigned')

/* R15 Protocol Room Priority            */ LEFT JOIN onprc_ehr.vet_assignment R15 ON (R15.Protocol.DisplayName = d.Protocol AND R15.Room = d.Room AND R15.Area IS NULL AND R15.Project IS NULL AND R15.Priority = true)
/* R16 Protocol Area Priority            */ LEFT JOIN onprc_ehr.vet_assignment R16 ON (R16.Protocol.DisplayName = d.Protocol AND R16.Area = d.Area AND R16.Room IS NULL AND R16.Project IS NULL AND R16.Priority = true)

/* R17 Protocol Room                     */ LEFT JOIN onprc_ehr.vet_assignment R17 ON (R17.Protocol.DisplayName = d.Protocol AND R17.Room = d.Room AND R17.Area IS NULL AND R17.Project IS NULL AND R17.Priority = false)
/* R18 Protocol Area                     */ LEFT JOIN onprc_ehr.vet_assignment R18 ON (R18.Protocol.DisplayName = d.Protocol AND R18.Area = d.Area AND R18.Room IS NULL AND R18.Project IS NULL AND R18.Priority = false)

/* R19 Protocol Priority                 */ LEFT JOIN onprc_ehr.vet_assignment R19 ON (R19.Protocol.DisplayName = d.Protocol AND R19.Area IS NULL  AND R19.Room IS NULL AND R19.Project IS NULL AND R19.Priority = true)
/* R20 Protocol                          */ LEFT JOIN onprc_ehr.vet_assignment R20 ON (R20.Protocol.DisplayName = d.Protocol AND R20.Area IS NULL  AND R20.Room IS NULL AND R20.Project IS NULL AND R20.Priority = false)

/* R21 Room                              */ LEFT JOIN onprc_ehr.vet_assignment R21 ON (R21.Room = d.Room AND R21.Area IS NULL AND R21.Protocol IS NULL AND R21.Project IS NULL AND R21.Priority = false)
/* R22 Area                              */ LEFT JOIN onprc_ehr.vet_assignment R22 ON (R22.Area = d.Area AND R22.Room IS NULL AND R22.Protocol IS NULL AND R22.Project IS NULL AND R22.Priority = false)
     )