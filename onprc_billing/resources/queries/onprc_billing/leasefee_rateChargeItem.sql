--20200113 Updated to look up active alias at time of assignment - Critical when dealing with Historic assignments
SELECT d.id,
d.CenterProject,
d.ProjectID,
d.alias as CurrentAlias,
h.account as AliasAtTime,
h.account.aliastype.removeSubsidy as RemoveSubsidy,
d.leasetype,
d.assignmentdate,
d.code,
d.ProjectedReleaseCode,
d.AssignmentAge,
d.chargeId,
r.chargeId.activeRate.subsidy,
r.chargeID.name as ChargeItem,
r.unitCost ,
p.multiplier,
e.UnitCost as ExemptionRate,
d.RevisedChargeID,
r1.chargeID.Name AS RevisedItem,
r1.chargeID.activeRate.subsidy as RevisedSubsidy,
r1.unitCost as RevisedUnitCost,
d.quantity
FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.leasefee_rateData d
	--Join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.Leasefee_leaseType t on d.id = t.id
	left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates r on d.chargeID = r.chargeID
		and (d.assignmentdate >= r.startDate and d.assignmentdate <= r.enddate)
	left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates r1 on d.RevisedchargeID = 	r1.chargeID and (d.assignmentdate >= r1.startDate and d.assignmentdate <= r1.enddate)
	left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.projectAccountHistory h on h.project = d.projectID and (d.assignmentdate >= h.startDate and d.assignmentDate <= h.enddate)
--add query  for exemption item
        left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeRateExemptions e on e.chargeID = d.chargeID and e.project = d.projectID
            and (d.assignmentdate >= e.startDate and d.assignmentDate <= e.enddate)
--add project multipler
     left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.ProjectMultipliers p on p.account = h.account and (d.assignmentDate >= p.startDate and d.assignmentdate <= p.enddate)