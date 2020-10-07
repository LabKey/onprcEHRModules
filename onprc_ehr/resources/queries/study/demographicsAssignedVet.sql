--Update 3/7/2019 load to test

Select
Distinct
d.Id,
d.room.area as Area,
d.room,
d.CaseVet,
d.protocol,
Case
    when d.DeceaseDAssignedVet is not null then d.DeceaseDAssignedVet
	when d.caseVet is not null then d.CaseVet
	when p3.userId is not null  then v1.userId.displayName
	when p4.userId is not null then  v2.userId.DisplayName
	when v1.userId is not null  then v1.userId.displayName
	when v2.userId is not null then  v2.userId.DisplayName
	when v3.userId is not null then  v3.userId.DisplayName
	when v4.userId is not null then  v4.userId.DisplayName
	when p1.userId is not null then  p1.userId.DisplayName
	when p2.userId is not null then   p2.userId.DisplayName
	when v5.userId is not null then  v5.userId.DisplayName
	when v6.userId is not null then  v6.userId.DisplayName
	when h1.userId is not null then  h1.userId.DisplayName
	when h2.userId is not null then h2.userId.DisplayName

	End as AssignedVet,

Case
    when d.DeceaseDAssignedVet is not null then 'Deceased or Shipped NHP'
	when d.caseVet is not null then 'Open Case'
	When p3.userId is not null then 'Protocol Room Priority'
	When p4.userId is not null then 'Protocol Area Priority'
	when v1.userId is not null  then 'Protocol Research Room'
	when v2.userId is not null then  'Protocol Research Area'
	when v3.userId is not null then  'Protocol Resource Room'
	when v4.userId is not null then  'Protocol Resource Area'
	when p1.userId  is not null then  'Room Priority'
	when p2.userId is not null then  'Area Priority'
	when v5.userId is not null then  'Protocol Research Only'
	when v6.userId is not null then  'Protocol Resource Only'

	when h1.userId is not null then 'Room Only'
	when h2.userId  is not null then 'Area Only'

	End as AssignmentType

FROM study.vet_assignmentDemographics d
--this handles REsearch Protocol Room
Left Join onprc_ehr.vet_assignment v1 on (v1.protocol.displayName = d.protocol and v1.room = d.room and d.assignmentType = 'Research Assigned')
--this handles Research Protocol Area
Left Join onprc_ehr.vet_assignment v2 on (v2.protocol.displayName = d.protocol  and v2.area = d.room.area and d.assignmentType = 'Research Assigned')
--this handles Resource Protocol Room
Left Join onprc_ehr.vet_assignment v3 on (v3.protocol.displayName = d.protocol  and v3.room = d.room and d.assignmentType = 'Resource Assigned')
--this handles Research Protocol Area
Left Join onprc_ehr.vet_assignment v4 on (v4.protocol.displayName = d.protocol  and v4.area = d.room.area and d.assignmentType = 'Resource Assigned')
--this handled Research Assigned No Additional Sekections
Left Join onprc_ehr.vet_assignment v5 on (v5.protocol.displayName = d.protocol   and v5.room is null and v5.area is null and d.assignmentType = 'Research Assigned' )
--this handles resource Protocol Only
Left Join onprc_ehr.vet_assignment v6 on (v6.protocol.displayName = d.protocol  and v6.room is null and v6.area is null  and d.assignmentType = 'Resource Assigned' )
--this handles when the room is a priorty
Left join onprc_ehr.vet_assignment p1 on (p1.room = d.room and p1.protocol is null and p1.priority = true)
--this handles when the room is a priorty-
Left join onprc_ehr.vet_assignment p2 on (p2.area = d.room.area and p2.protocol is null and p2.priority = true)
--THis handles when a priority is placed on Room and Protocol --
Left Join onprc_ehr.vet_assignment p3 on (p3.protocol.displayName = d.protocol and p3.room = d.room and p3.priority = true)
--THis handles when a priority is placed on Areaand Protocol -
Left Join onprc_ehr.vet_assignment p4 on (p4.protocol.displayName = d.protocol  and p4.area = d.room.area and p4.priority = true)
--these deal with assignment based on housing only
Left join onprc_ehr.vet_assignment h1 on (h1.room = d.room and h1.protocol is null and h1.area is null and h1.priority = false)
Left join onprc_ehr.vet_assignment h2 on (h2.area = d.room.area and h2.room is null and h2.protocol is null and h2.priority = false)
where d.id not like '[a-z]%'