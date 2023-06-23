--2021/03/09  Update to include Project
--2023-0621 Clean up of code and review with Lakshmi

select *
from (Select Distinct d.Id,
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
                          when Rule_1.userId is not null then Rule_1.userId.displayName
                          when Rule_1.userId is not null then Rule_2.userId.DisplayName
                          when Rule_3.userID is not null then Rule_3.userID.displayName
                          when Rule_4.userID is not null then Rule_4.userID.displayName
                          when Rule_5.userID is not null then Rule_5.userID.displayName
                          when Rule_6.userID is not null then Rule_6.userID.displayName
                          when Rule_7.userID is not null then Rule_7.userID.displayName
                          when Rule_8.userId is not null then Rule_8.userId.displayName
                          when Rule_9.userId is not null then Rule_9.userId.DisplayName
                          when Rule_10.userId is not null then Rule_10.userId.DisplayName
                          when Rule_11.userId is not null then Rule_11.userId.DisplayName
                          when Rule_12.userId is not null then Rule_12.userId.DisplayName
                          when Rule_13.userId is not null then Rule_13.userId.DisplayName
                          when Rule_14.userId is not null then Rule_14.userId.DisplayName
                          when Rule_15.userId is not null then Rule_15.userId.DisplayName
                          when Rule_16.userId is not null then Rule_16.userId.DisplayName
                          End  as AssignedVet,
                      Case
                          when d.caseVet is not null then 'Open Case'
                          when rule_1.userId is not null then 'Room Priority'
                          when rule_2.userId is not null then 'Area Priority'
                          When rule_3.userID is not null then 'Project Room Research'
                          When rule_4.userID is not null then 'Project Room Resource'
                          When rule_5.userID is not null then 'Project Area Research'
                          When rule_6.userID is not null then 'Project Area Resource'
                          when rule_7.userID is not null then 'Project Research'
                          when rule_8.userID is not null then 'Project Resource'
                          When rule_9.userId is not null then 'Protocol Room Priority'
                          When rule_10.userId is not null then 'Protocol Area Priority'
                          when rule_11.userId is not null then 'Protocol  Room'
                          when rule_12.userId is not null then 'Protocol Area'
                          when rule_13.userId is not null then 'Protocol High Only'
                          when rule_14.userId is not null then 'Protocol'
                          when rule_15.userId is not null then 'Room Only'
                          when rule_16.userID is not null then 'Area only'
                          End as AssignmentType

      FROM study.vet_assignmentDemographics d

--Rule_1 Room Priority
               Left join onprc_ehr.vet_assignment Rule_1 on (Rule_1.room = d.room and Rule_1.room.area is null and Rule_1.project is null and Rule_1.protocol is null and Rule_1.priority = true)
--Rule 2 Area Priority
               Left join onprc_ehr.vet_assignment Rule_2 on (Rule_2.area = d.room.area and Rule_2.room is null and Rule_2.project is null and  Rule_2.protocol is null and Rule_2.priority = true)
--Rule 3 Project Room Research
               Left Join onprc_ehr.vet_assignment Rule_3 on (Rule_3.project = d.project and Rule_3.room = d.room and Rule_3.room.area is null and Rule_3.protocol is null and Rule_3.priority = false and d.assignmentType = 'Project Research Assigned')
--Rule 4 Project Room Resource
               Left Join onprc_ehr.vet_assignment Rule_4 on (Rule_4.project = d.project and Rule_4.room = d.room and Rule_4.room.area is null and Rule_4.Protocol is null and Rule_4.priority = false and d.assignmentType = 'Project Resource Assigned')
--Rule 5 Project Area Research
               left Join onprc_ehr.vet_assignment Rule_5 on (Rule_5.project = d.project and Rule_5.area = d.room.area and Rule_5.room is null and Rule_5.protocol is null and Rule_5.priority = false and d.assignmentType = 'Project Research Assigned')
--Rule 6 Project Area Resource
               left Join onprc_ehr.vet_assignment Rule_6 on (Rule_6.project = d.project and Rule_6.area = d.room.area and Rule_6.room is null and Rule_6.Protocol is null and Rule_6.priority = false and d.assignmentType = 'Project Resource Assigned')
--Rule 7 Project Research
               left Join onprc_ehr.vet_assignment Rule_7 on (Rule_7.project = d.project and Rule_7.area is null and Rule_7.room is null and Rule_7.protocol is null and Rule_7.priority = false and d.assignmentType = 'Project Research Assigned')
--Rule 8 Project Resource
               Left Join onprc_ehr.vet_assignment Rule_8 on (Rule_8.project = d.project and Rule_8.area is null and Rule_8.room is null and Rule_8.protocol is null and Rule_8.priority = false and d.assignmentType = 'Project Resource Assigned')
--Rule 9 Protocol Room Priority
               Left Join onprc_ehr.vet_assignment Rule_9 on (Rule_9.protocol.displayName = d.protocol and Rule_9.room = d.room and Rule_9.area is null and Rule_9.project is null and Rule_9.priority = True)
--Rule 10 Protocol Area Priority
               Left Join onprc_ehr.vet_assignment Rule_10 on (Rule_10.protocol.displayName = d.protocol and Rule_10.area = d.room.area and Rule_10.priority = True)
--Rule 11 Protocol Room
               Left Join onprc_ehr.vet_assignment Rule_11 on (Rule_11.protocol.displayName = d.protocol and Rule_11.room = d.room and Rule_11.project is null and Rule_11.area is null and Rule_11.priority = false)
--Rule 12 Protocol Area
               Left Join onprc_ehr.vet_assignment Rule_12 on (Rule_12.protocol.displayName = d.protocol and Rule_12.area = d.room.area and Rule_12.project is null and Rule_12.room is null and Rule_12.priority = false)
--Rule 13 Protocol Priority
               Left Join onprc_ehr.vet_assignment Rule_13 on (Rule_13.protocol.displayName = d.protocol and Rule_13.area is null and Rule_13.room is null and Rule_13.project is null and Rule_13.priority = True)
--Rule 14 Protocol
               Left Join onprc_ehr.vet_assignment Rule_14 on (Rule_14.protocol.displayName = d.protocol and Rule_14.area is null and Rule_14.room is null and Rule_14.project is null and Rule_14.priority = false)
--Rule 15 Room
               Left Join onprc_ehr.vet_assignment Rule_15 on (Rule_15.room = d.room and Rule_15.area is null and Rule_15.protocol is null and  Rule_15.project is null and Rule_15.priority = false)
--Rule 16 Area
               Left Join onprc_ehr.vet_assignment Rule_16 on (Rule_16.area = d.room.area and Rule_16.room is null and Rule_16.protocol is null and Rule_16.project is null and Rule_16.priority = false))
--where d.id not like '[a-z]%'