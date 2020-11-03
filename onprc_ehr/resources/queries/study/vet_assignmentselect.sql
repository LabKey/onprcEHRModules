SELECT
d.Id,
d.room.area as Area,
d.room,

Case
	when d.deceaseDAssignedVet is not null then 'Deceased NHP'
	when d.caseVet is not null then 'Open Case'
	when v1.userId.userId.DisplayName is not null  then 'research Room'
	when v2.userId.userId.DisplayName is not null then  'REsearch Area'
	when v3.userId.userId.DisplayName is not null then  'Resource Room'
	when v4.userId.userId.DisplayName is not null then  'Resource Area'
	when v5.userId.userId.DisplayName is not null then  'Research Only'
	when v6.userId.userId.DisplayName is not null then  'Resource Only'
	when p1.userId.userId.DisplayName  is not null then  'Room Priority'
	when p2.userId.userId.DisplayName is not null then  'AreaPriority'
	when h1.userId.userId.DisplayName is not null then 'Room Only'
	when h2.userId.userId.DisplayName  is not null then 'Area Only'
 	Else ' '
	End as AssignmentType,

d.deceaseDAssignedVet as DeceasedVet,
d.CaseVet,
v1.userId.userId.DisplayName as ResearchRoom,
v2.userId.userId.DisplayName as REsearchArea,
v3.userId.userId.DisplayName as REsourceRoom,
v4.userId.userId.DisplayName as ResourceArea,
v5.userId.userId.DisplayName as ResearchOnly,
v6.userId.userId.DisplayName as ResourceOnly,
p1.userId.userId.DisplayName as RoomPriority,
p2.userId.userId.DisplayName as AreaPriority,
h1.userId.userId.DisplayName as RoomOnly,
h2.userId.userId.DisplayName as AreaOnly


FROM study.vet_assignmentDemographics d
--this handles REsearch Protocol Room
Left Join onprc_ehr.vet_assignment v1 on (v1.protocol = d.protocol and v1.room = d.room and d.assignmentType = 'Research Assigned')
--this handles Research Protocol Area
Left Join onprc_ehr.vet_assignment v2 on (v2.protocol = d.protocol and v2.area = d.room.area and d.assignmentType = 'Research Assigned')
--this handles Resource Protocol Room
Left Join onprc_ehr.vet_assignment v3 on (v3.protocol = d.protocol and v3.room = d.room and d.assignmentType = 'Resource Assigned')
--this handles Research Protocol Area
Left Join onprc_ehr.vet_assignment v4 on (v4.protocol = d.protocol and v4.area = d.room.area and d.assignmentType = 'Resource Assigned')
--this handled Research Assigned No Additional Sekections
Left Join onprc_ehr.vet_assignment v5 on (v5.protocol = d.protocol  and d.assignmentType = 'Research Assigned' and (v5.area is null and v5.room is null))
--this handles resource Protocol Only
Left Join onprc_ehr.vet_assignment v6 on (v6.protocol = d.protocol  and d.assignmentType = 'Resource Assigned' and (v6.area is null and v5.room is null))
--this handles when the room is a priorty
Left join onprc_ehr.vet_assignment p1 on (p1.room = d.room and p1.priority = true)
--this handles when the room is a priorty
Left join onprc_ehr.vet_assignment p2 on (p2.area = d.room.area and p2.priority = true)
Left join onprc_ehr.vet_assignment h1 on (h1.room = d.room and h1.priority = false)
Left join onprc_ehr.vet_assignment h2 on (h2.area = d.room.area and h2.priority = false)
