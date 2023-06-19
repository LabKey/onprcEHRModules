--2021/03/09  Update to include Project
-- 2023-05-30 Latest update
--2023-06-01 Update to include Project
--2023-06-15 Update to Project


Select
    Distinct
    d.Id,
    d.room.area as Area,
    d.room,
    d.CaseVet,
    d.project,
    d.assignmentType as CodeAssignmentType,
    d.protocol,
    d.ProtocolPI,
    d.Calculated_status,
    Case
        --  when d.DeceaseDAssignedVet is not null then d.DeceaseDAssignedVet
        when d.caseVet is not null then d.CaseVet
        when p1.userId is not null  then p1.userId.displayName
        when p2.userId is not null then  p2.userId.DisplayName
        when s3.userID is not null then  s3.userID.displayName
        when s4.userID is not null then  s4.userID.displayName
        when s5.userID is not null then  s5.userID.displayName
        when s6.userID is not null then  s6.userID.displayName
        when s1.userID is not null then  s1.userID.displayName
        when s2.userID is not null then  s2.userID.displayName
        when v1.userId is not null  then v1.userId.displayName
        when v2.userId is not null then  v2.userId.DisplayName
        when v3.userId is not null then  v3.userId.DisplayName
        -- when v4.userId is not null then  v4.userId.DisplayName
        when p3.userId is not null then  p3.userId.DisplayName
        when p4.userId is not null then  p4.userId.DisplayName
        --    when v5.userId is not null then  v5.userId.DisplayName
        when v6.userId is not null then  v6.userId.DisplayName
        when h1.userId is not null then  h1.userId.DisplayName
        when h2.userId is not null then  h2.userId.DisplayName

        End as AssignedVet,

    Case
        -- when d.DeceaseDAssignedVet is not null then 'Deceased or Shipped NHP'
        when d.caseVet is not null then 'Open Case'
        when p1.userId  is not null then  'Room Priority'
        when p2.userId is not null then  'Area Priority'
        When s3.userID is not null then 'Project Room Research'
        When s4.userID is not null then 'Project Room Resource'
        When s5.userID is not null then 'Project Area Research'
        When s6.userID is not null then 'Project Area Resource'
        WHen s7.userID is not null then 'Project Research Priority'
        When s8.userID is not null then 'Project Resource Priority'
        when s1.userID is not null then 'Project Research'
        when s2.userID is not null then 'Project Resource'
        When p3.userId is not null then 'Protocol Room Priority'
        When p4.userId is not null then 'Protocol Area Priority'
        when v1.userId is not null  then 'Protocol Room'
        when v2.userId is not null then  'Protocol Area'
        when v3.userId is not null then  'Protocol Priority'
        when v6.userid is not null then  'Protocol'
        when h1.userId is not null then 'Room Only'
        when h2.userId  is not null then 'Area Only'

        End as AssignmentType
c
FROM study.vet_assignmentDemographics d
--ROOM- High Priority
         Left join onprc_ehr.vet_assignment p1 on (p1.room = d.room and p1.protocol is null and p1.priority = true)
--Area - High Priority
         Left join onprc_ehr.vet_assignment p2 on (p2.area = d.room.area and p2.protocol is null and p2.priority = true)
--Project + Room (Research)
         Left Join onprc_ehr.vet_assignment s3 on (s3.project = d.project and s3.room = d.room and d.assignmentType = 'Project Research Assigned')
--Project + Room (Resource)
         Left Join onprc_ehr.vet_assignment s4 on (s4.project = d.project and s4.room = d.room and d.assignmentType = 'Project Resource Assigned')
--Project + Area (Research)
         Left Join onprc_ehr.vet_assignment s5 on (s5.project = d.project  and s5.area = d.room.area and d.assignmentType = 'Project Research Assigned')
--Project + Area  (Resource)
         Left Join onprc_ehr.vet_assignment s6 on (s6.project = d.project  and s6.area = d.room.area and d.assignmentType = 'Project Resource Assigned')
--Project (research) High Priority
         Left Join onprc_ehr.vet_assignment s7 on (s7.project = d.project and s7.priority = true and d.assignmentType = 'Project Research Assigned')
--Project  (Resource) High Priority)
         Left Join onprc_ehr.vet_assignment s8 on (s8.project = d.project and s8.priority = true and d.assignmentType = 'Project Resource Assigned')
--Project (Research)
         Left Join onprc_ehr.vet_assignment s1 on (s1.project = d.project and d.assignmentType = 'Project Research Assigned')
--Project (Resource)
         Left Join onprc_ehr.vet_assignment s2 on (s2.project = d.project and d.assignmentType = 'Project Resource Assigned')
--Protocol Room HIgh Priority
         Left Join onprc_ehr.vet_assignment p3 on (p3.room = d.room and p3.protocol.displayName = d.protocol and p3.priority = true)
--Protocol Area High Priority
         Left Join onprc_ehr.vet_assignment p4 on (p4.area = d.room.area and p4.protocol.displayName = d.protocol and p4.priority = true)
--Protocol Room
         Left Join onprc_ehr.vet_assignment v1 on (v1.protocol.displayName = d.protocol and v1.room = d.room )
--Protocol Area
         Left Join onprc_ehr.vet_assignment v2 on (v2.protocol.displayName = d.protocol and v2.area = d.room.area )
--Protocol High Priority
         Left Join onprc_ehr.vet_assignment v3 on (v3.protocol.displayName = d.protocol and v3.priority = true)
--Protocol
         Left Join onprc_ehr.vet_assignment v6 on (v6.protocol.displayName = d.protocol)
--Room
         Left join onprc_ehr.vet_assignment h1 on (h1.room = d.room and h1.protocol is null and h1.area is null and h1.priority = false)

         Left join onprc_ehr.vet_assignment h2 on (h2.area = d.room.area and h2.room is null and h2.protocol is null and h2.priority = false)
