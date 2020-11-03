SELECT l.id,
l.project.name as CenterProject,
l.project.project as ProjectID,
l.alias,
l.leasetype,
l.assignmentdate,
l.assignCondition.code,

l.projectedReleaseCondition.code as ProjectedReleaseCode,
Cast(l.ageAtAssignment as Integer) as AssignmentAge,
Case

	when (l.leasetype  = 'U42 Expanded SPF Lease' and l.daylease <> 'yes') then 5348
    When (l.leaseType = 'Obese 0622-01  Day Lease'  and l.leasetype = lf.chargeID.name) then 5367
	When (l.leaseType = 'Obese JMac Control Infant' and l.daylease <> 'yes' and l.leasetype = lf.chargeID.name) then 5372
	When (l.leaseType = 'Obese JMac WSD Infant' and l.daylease <> 'yes' and l.leasetype = lf.chargeID.name) then 5371
	When (l.leaseType = 'OBESE Adult Male Lease' and l.daylease <> 'yes' and l.leasetype = lf.chargeID.name) then 5368
	When (l.leaseType = 'OBESE Adult Terminal Leasel' and l.daylease <> 'yes' and l.leasetype = lf.chargeID.name) then 5369
	When (l.leaseType = 'OBESE Adult Day Lease'  and l.leasetype = lf.chargeID.name) then 5367
    When (l.leaseType = 'Day Lease Research Assignment P51 NHP Condition Change'  and l.leasetype = lf.chargeID.name) then 9999
	When (l.leaseType = 'Day Lease Research Assignment P51 NHP NC' ) then 90
	When (l.leaseType = 'DualAssignedESPF' and l.daylease <> 'yes' and l.leasetype = lf.chargeID.name) then null
    when (l.leasetype  = 'Animal Lease Fee - TMB') and l.daylease <> 'yes' then 1552

	When (l.leaseType = 'TMB Adult Day Lease'  and l.leasetype = lf.chargeID.name) then 90
	When (l.leaseType = 'TMB No Charge'  and l.leasetype = lf.chargeID.name) then Null
	When (l.leaseType = 'TMB Full P 51 Rate Lease'  and l.leasetype = lf.chargeID.name) then
		(Select lf1.ChargeID from Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf1
         where lf1.assignCondition = l.assignCondition
             AND lf1.releaseCondition = l.projectedReleaseCondition
             AND (l.ageAtAssignment >= lf1.minAge OR lf1.minAge IS NULL)
             AND (l.ageAtAssignment < lf1.maxAge OR lf1.maxAge IS NULL)
             AND lf1.active = true)
	when (l.leasetype like 'Research Assignment P51 %' and l.daylease <> 'yes')  then
		(Select lf2.ChargeID from Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf2
         where lf2.assignCondition = l.assignCondition
             AND lf2.releaseCondition = l.projectedReleaseCondition
             AND (l.ageAtAssignment >= lf2.minAge OR lf2.minAge IS NULL)
             AND (l.ageAtAssignment < lf2.maxAge OR lf2.maxAge IS NULL)
             AND lf2.active = true)


	When (l.leaseType = 'Born to Resource Dam' ) then Null
	Else Null
	End as chargeID,
--lf.chargeId,
Null as RevisedChargeID,

1 as quantity

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.leaseFee_LeaseType l left outer join
  Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf on l.leaseType = lf.chargeID.name