
SELECT
l.id,
l.researchOwned,
l.project,
l.alias,
l.ageatAssignment,
l.ageinYears,
l.AgeGroup,
l.BirthAssignment,
l.BirthType,
l.AssignmentType,
l.daylease,
Case
	when l.dayleaseLength = 0 then 1
	else l.dayLeaseLength
	end as DayLeaseLength,
l.multipleAssignments,
l.CreditResource,
l.creditTo,
l.date as AssignmentDate,
l.projectid,
l.projectedRelease,
l.enddate as ReleaseDate,
l.dateFinalized,
l.assignCondition,
l.projectedReleaseCondition,
l.releaseCondition,
l.releaseType,
l.remark,
l.faRate,
l.removesubsidy,
l.canRaiseFA,

--this provides the recorded dam for the NHP assocatied to the assignment
b.dam,
da.project as DualAssigned,
Case
--Research Owned Animal
	When l.researchowned = 'yes' then 'researchOwned'
--Adult Research Assignment P51 Animal (animal unassigned and adult)
----**Dual Assigned Obese JMac Control Infant Lease
	When l.id.age.ageinyears < 3 and da.projectname  = '0622-01'and (l.id !=r.id or r.id is null) then 'Obese JMac Control Infant'
----**Dual Assigned Obese JMac WSD Infant Lease
	When l.id.age.ageinyears < 3 and da.projectname  = '0622-01'and l.id =r.id then 'Obese JMac WSD Infant'
	--Adult Day Lease Condition Change for Research Assigned Adults -  remove Age restriction
	When (l.id.age.ageinyears > 1 and l.dayLease = 'yes' and l.assignCondition = l.projectedReleaseCondition) and (da.projectname  != '0833' or da.projectname is Null ) then 'Day Lease Research Assignment P51 NHP NC'
	--Adult Day L:ease No Condition Change
	When (l.id.age.ageinyears > 1 and l.dayLease = 'yes' and l.assignCondition != l.projectedReleaseCondition) and (da.projectname  != '0833' or da.projectname is Null) then 'Day Lease Research Assignment P51 NHP Condition Change'
--Dual assigned ESPF using different Chared Code
--	When da.projectName  = '0492-03' then 'DualAssignedESPF'
--Dual assigned TMB Male on Day Lease
	When l.agegroup = 'Adult'  and da.projectname = '0300'  and l.dayLease = 'yes' then 'TMB Adult Day Lease'
--Dual assigned Obese Male Day Lease
	When l.agegroup = 'Adult'  and da.projectname = '0833'  and l.dayLease = 'yes' then 'OBESE Adult Day Lease'
--Full LEase P51 adult
	When l.id.age.ageinyears > 1 and l.daylease <> 'yes' and (da.projectname  <> '0833' or da.projectName is Null) then 'Research Assignment P51 Adult'
--**Dual Assigned TMB-Dam Assigned Use lease_TMB as Process --------------------------------------------------------------------------------------------------------
-- For No charge Dam is Dual assigned to TMB and to the Project and Infant is assigned to the Project - THe lease for infant is built into the TMB Lease of the Dam
	WHEN L.Birthtype = 'TMBResearchAssignment' then 'TMB No Charge'
--**Dual Assigned TMB Dam Not Assigned ----------------------------------------------------------------------------------------------------------------------------
-- For this the INfant and Dam are not assigned to the same project and the dam is assigned to TMB
	WHEN L.Birthtype = 'TMB DAm Not Assigned' then 'TMB Full P 51 Rate Lease'
--Infant born to Resource Dam
	When l.birthType = 'Born to Resource Dam' then l.birthType
--handle Birth to resource and research at birth --handle it
/*********Dual Assigned ESPFTMB Birth */
	When da.projectName  = '0492-03' then 'DualAssignedESPF'
----Dual Assigned Obese JMac Infant or Dam Day Lease = No condition Code CHanges - if change full lease
	When da.projectname   = '0622-01'  and l.daylease = 'yes' then 'Obese 0622-01  Day Lease'
----**Dual Assigned Obese JMac Control Infant Lease
	When l.id.age.ageinyears < 3 and da.projectname  = '0622-01'and l.id !=r.id then 'Obese JMac Control Infant'
----**Dual Assigned Obese JMac WSD Infant Lease
	When l.id.age.ageinyears < 3 and da.projectname  = '0622-01'and l.id =r.id then 'Obese JMac WSD Infant'
----**Dual Assigned Obese Adult Day Lease
	When l.agegroup = 'adult' and da.projectname  = '0833' and l.daylease = 'yes' then 'OBESE Adult Day Lease'
----**Dual Assigned Obese Adult Male Lease
	When l.agegroup = 'adult' and da.projectname  = '0833' and l.daylease = 'no' and Cast(l.projectedReleaseCondition as Varchar(20)) != 'Terminal' then 'OBESE Adult Male Lease'
----Dual Assigned Obese Adult Male Terminal Lease
	When l.agegroup = 'adult' and da.projectname  = '0833' and l.daylease = 'no' and Cast(l.projectedReleaseCondition as Varchar(20)) = 'Terminal' then 'OBESE Adult Terminal Leasel'
--when Adult Animal Assigned to Research project
	when l.agegroup = 'adult' and da.project  ='0300' then 'Aninal Lease Fee -TMB'
--Infant Research Assignment P51 Animal Day Lease -------------------------------------------------------------------------------------------------------
	When l.id.age.ageinyears < 1 and l.daylease = 'yes' then 'Day Lease Research Assignment P51 Infant'
--Infant Research Assignment P51 Animal-------------------------------------------------------------------------------------------------------
	When l.ageatAssignment < 1 then 'Research Assignment P51 Infant'
Else 'UnDeteremined'
End As LeaseType,

/*Case
--Dual Assigned 0492-02
	When  da.projectname = '0492-02' then 'Dual Assigned U42'
--Dual Assigned 0492-45
   When da.projectname = '0492-45' then 'Dual Assigned JMR'
--Dual Assigned 0689
	When da.projectname  = '0689' then 'Dual Assigned IDR Orphanage'
--Dual Assigned 0456
	When da.projectname =  '0456' then 'Dual Assigned Aging'
When da.projectName  = '0492-03' then 'DualAssignedESPF'
else 'P-51'
ENd as CreditTo,
*/

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_demographics l
	left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.birth b on l.id = b.id
	left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.lease_ObeseInfant_HFDDam R on l.id = r.id
	Left outer join Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.dualassigned da on da.id = l.id and (da.dualassignment = l.project
            and (da.enddate is null or da.enddate > l.date) and (da.dualenddate is null or Dualenddate > l.date))
where l.researchowned = 'no'