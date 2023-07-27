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
                           WHEN R21.UserID IS NOT NULL THEN R21.UserID.DisplayName --Rule 21 is triggering a data type issue
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
