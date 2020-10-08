SELECT r.Id,
r.date as BillingDate,
r.enddate as ReleaseDate,
r.CenterProject,
r.AliasAtTime,

--r.ageinyears,
--r.AgeGroup,
r.projectedReleaseCondition,
r.assignCondition,
r.releaseCondition,
r.releaseType,
r.AgeAtAssignment as AgeAtTime,
r.item as ChargeName,
r.ServiceCenter,
Case
	When r.item = 'Lease Fee Adjustment' then a.leaseCharge1.name
	else null
	end  as OriginalLeaseType,
a.leaseCharge2  as FinalLeaseType,
r.AssignmentType as ChargeCategory,
r.CalculatedRate as UnitCost,
cr.unitCost as NIHRate,
--r.DayLease,

--case statement when dayeleaselength > 0 then dayleasr leanth else 1  as quantity
case
    when r.DayLeaseLength> 0 then r.dayleaseLength
    Else 1
    End as Quantity,
--Credit Alias Need to
r.MultipleAssignments,
--r.date,
r.projectedRelease,
r.datefinalized,
--r.releaseCondition,
--r.releaseType,
r.remark,
r.alias,
r.ChargeID,
--r.Item,
r.exemptionRate,
r.Multiplier,
r.subsidy,

--r.revisedChargeID,
r.revisedSubsidy,
r.leasetype,
r.ResearchOwned,
r.farate,
r.removesubsidy,
r.canRaiseFA,
r.BirthAssignment,
r.BirthType,
case
    When d.creditResource is not Null then d.creditResource
    Else 'p51'
    End as CreditTo,
Case
When d.creditResource is not Null then d.creditTo
    else ca.account
    End  as CreditAccount,
case
    when r.DayLeaseLength> 0 then (r.dayleaseLength * r.CalculatedRate)
    when r.revisedrate is not null and r.revisedrate > r.CalculatedRate then (r.revisedRate - r.CalculatedRate)
    when r.revisedrate is not null and r.revisedrate < r.CalculatedRate then (r.CalculatedRate - r.RevisedRate)

    Else (1 * r.CalculatedRate)
    End as TotalCost,
r.revisedRate


--Fields to Add
--Is Exemption
--Is Non Standard Rate
--Ie Manually Entered
--Is Adjustment/Reversal
---Missing Alias
--Alias Accepting Charges
--Expired Alias
-->45 Days Olde
--Is Assigned at Tom
--IS Assigned to Protocol at Time

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeRates_2020 r
	left outer join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeReleaseAdjustment a on a.id = r.id and a.date = r.date
    left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates cr on r.chargeID = cr.chargeID and (cr.startDate <= r.date and cr.enddate >= r.date or cr.enddate is null)
    left outer join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.creditAccount ca on ca.chargeID = r.chargeID and (r.Date > ca.startDate and r.Date <= ca.enddate)
    --left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates cr on r.chargeID = cr.chargeID and (cr.startDate <= r.date and cr.enddate >= r.date or cr.enddate is null)
  --left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.LeaseFeeRates_CreditTo ct on r.chargeID = ct.chargeID and ct.id <= r.id  and ct.assignmentDate = r.date
    Left outer join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFee_Demographics d on r.id = d.id and r.date = d.date and r.project = d.project