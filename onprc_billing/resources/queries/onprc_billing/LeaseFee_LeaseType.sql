/*
Query Name:		Leasefee_LeaseType
Purpose:		The purpose of this query is to determine the Lease type based on the Conidtions defined in the Lease Type statement
Created by:		Gary Jones
Dependency:		onprc_billing.leasefee_demographics
				study.birth
				study.lease_ObeseInfant_HFDDam
Narrative:
Reading the data from LeaseFee_Demographics to assist in determine the lease type for billing processes
THere are 20 separate conditions that result in a lease fee being selected
??Why do I need the assignment table when the needed data is available from leaseFee-Demographics
--TODO Look at the Adjustments at time of Release
COndition Code Change
00Not if PI Owned]
Not if ESPF one use Animal
Obese - TMB - ESPF
--Update 2020-01-10 Changes ESPF to U42 Expanded SPF Lease so that will properly display
--2020-01-15 Update to handle TMB Adult Assignment

*/

SELECT
l.id,
Case
--Research Owned Animal
When l.researchowned = 'yes' then 'researchOwned'
--Adult Research Assignment P51 Animal (animal unassigned and adult)
----**Dual Assigned Obese JMac Control Infant Lease
When l.id.age.ageinyears < 3 and da.project.name = '0622-01'and (l.id !=r.id or r.id is null) then 'Obese JMac Control Infant'
----**Dual Assigned Obese JMac WSD Infant Lease
When l.id.age.ageinyears < 3 and da.project.name = '0622-01'and l.id =r.id then 'Obese JMac WSD Infant'


--Adult Day Lease Condition Change for Research Assigned Adults - remove Age restriction
When (l.id.age.ageinyears > 1 and l.dayLease = 'yes' and l.assignCondition = l.projectedReleaseCondition) and (da.project.name != '0833' or da.project.name is Null ) then 'Day Lease Research Assignment P51 NHP NC'
--Adult Day L:ease No Condition Change
When (l.id.age.ageinyears > 1 and l.dayLease = 'yes' and l.assignCondition != l.projectedReleaseCondition) and (da.project.name != '0833' or da.project.name is Null) then 'Day Lease Research Assignment P51 NHP Condition Change'

--Dual assigned ESPF using different Chared Code
When da.project.Name = '0492-03' then 'U42 Expanded SPF Lease'
--Dual assigned TMB Male on Day Lease
When l.agegroup = 'Adult' and da.project.name = '0300' and l.dayLease = 'yes' then 'TMB Adult Day Lease'


/*********Dual Assigned TMB Dam */
When l.MultipleAssignments = 'TMB Dam' then 'Animal Lease Fee -TMB'
--Full LEase P51 adult
When l.id.age.ageinyears > 1 and l.daylease <> 'yes' and (da.project.name <> '0833' or da.project.Name is Null) then 'Research Assignment P51 Adult'

--**Dual Assigned TMB-Dam Assigned Use lease_TMB as Process --------------------------------------------------------------------------------------------------------

-- For No charge Dam is Dual assigned to TMB and to the Project and Infant is assigned to the Project - THe lease for infant is built into the TMB Lease of the Dam
WHEN L.Birthtype = 'TMBResearchAssignment' then 'TMB No Charge'

--**Dual Assigned TMB Dam Not Assigned ----------------------------------------------------------------------------------------------------------------------------
-- For this the INfant and Dam are not assigned to the same project and the dam is assigned to TMB
WHEN L.Birthtype = 'TMB DAm Not Assigned' then 'TMB Full P 51 Rate Lease'
-- TMB Dam is TMB and is assigned to Research to produce infant
-- When l.id in (Select d1.id from study.tmbdam d1 where d1.id = l.id and d1.date < l.date and l.enddate is Null) and l.project.Use_category = 'Research'
-- then 'TMB Dam Research Assignment'
--Infant born to Resource Dam
When l.birthType = 'Born to Resource Dam' then l.birthType

----Dual Assigned Obese JMac Infant or Dam Day Lease = No condition Code CHanges - if change full lease
--need to change to also incldue if the damn is there
When da.project.name = '0622-01' and l.daylease = 'yes' then 'Obese 0622-01 Day Lease'
----**Dual Assigned Obese JMac Control Infant Lease
When l.id.age.ageinyears < 3 and da.project.name = '0622-01'and l.id !=r.id then 'Obese JMac Control Infant'
----**Dual Assigned Obese JMac WSD Infant Lease
When l.id.age.ageinyears < 3 and da.project.name = '0622-01'and l.id =r.id then 'Obese JMac WSD Infant'
----**Dual Assigned Obese Adult Day Lease
When l.agegroup = 'adult' and da.project.name = '0833' and l.daylease = 'yes' then 'OBESE Adult Day Lease'
----**Dual Assigned Obese Adult Male Lease
When l.agegroup = 'adult' and da.project.name = '0833' and l.daylease = 'no' and Cast(l.projectedReleaseCondition as Varchar(20)) != 'Terminal' then 'OBESE Adult Male Lease'
----Dual Assigned Obese Adult Male Terminal Lease
When l.agegroup = 'adult' and da.project.name = '0833' and l.daylease = 'no' and Cast(l.projectedReleaseCondition as Varchar(20)) = 'Terminal' then 'OBESE Adult Terminal Leasel'
--when Adult Animal Assigned to Research project
--when l.agegroup = 'adult' and da.project ='0300' then 'Aninal Lease Fee -TMB'
--Infant Research Assignment P51 Animal Day Lease -------------------------------------------------------------------------------------------------------
When l.id.age.ageinyears < 1 and l.daylease = 'yes' then 'Day Lease Research Assignment P51 Infant'

--Infant Research Assignment P51 Animal-------------------------------------------------------------------------------------------------------
When l.ageatAssignment < 1 then 'Research Assignment P51 Infant'



Else 'UnDeteremined'
End As LeaseType,
Case

--Dual Assigned 0492-02
	When  da.project.name = '0492-02' then 'Dual Assigned U42'
--Dual Assigned 0492-45
   When da.project.name = '0492-45' then 'Dual Assigned JMR'
--Dual Assigned 0689
	When da.project.name  = '0689' then 'Dual Assigned IDR Orphanage'
--Dual Assigned 0456
	When da.project.name =  '0456' then 'Dual Assigned Aging'
When da.project.Name  = '0492-03' then 'DualAssignedESPF'
else 'P-51'

ENd as CreditTo,



l.date as AssignmentDate,
l.projectedRelease,
l.enddate as ReleaseDate,
l.daylease,
Case
	when l.dayleaseLength = 0 then 1
	else l.dayLeaseLength
	end as DayLeaseLength,
l.project,
--this provides the recorded dam for the NHP assocatied to the assignment
b.dam,
--Need to determine the assignment of the dam at the time of the assignment it the lease is at the time of birth
----Use the value from leasefee Demograpbhics to determine if the lease being reviewed is at the time of the animal birth
----If the assignment is at the time of the animal birth then determine who the dam was and what was the Dam assignment at the time of birth
--Case
	--WHen l.birthassignment = 'yes' then --'yes'
		--then
	--determine if mom is a resource dam
	--	(Select  g.groupID.name from study.animal_Group_Members g where g.id = (Select Dam from study.birth b1 where b1.id = l.id) and g.enddate is null)
	--Else 'Non Birth Lease'


--End as ResourceBirth,
--(Select  g.groupID.name from study.animal_Group_Members g where g.id = (Select Dam from study.birth b1 where b1.id = a.id) and g.enddate is null) as ResourceDamBirth,

--need age at time of assignment this will come from LEaseFee_Demographics
l.ageatAssignment,
l.AgeGroup,
l.BirthAssignment,
l.BirthType,
l.AssignmentType,
da.project as DualAssigned,

l.assignCondition,
l.projectedReleaseCondition,
l.releaseCondition,
l.releaseType,
l.remark,
l.alias,
l.faRate,
l.removesubsidy,
l.canRaiseFA,
l.project.project as projectID
FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_demographics l
	left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.birth b on l.id = b.id
	left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.lease_ObeseInfant_HFDDam R on l.id = r.id
	Left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.dualassigned da on da.id = l.id and (da.dualassignment = l.project
            and (da.enddate is null or da.enddate > l.date) and (da.dualenddate is null or Dualenddate > l.date))
where l.researchowned = 'no'