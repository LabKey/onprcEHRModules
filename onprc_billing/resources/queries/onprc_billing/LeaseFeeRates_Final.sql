--2020/02/12 build

SELECT
r.Id,
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
r.revisedChargeID  as FinalLeaseType,
r.AssignmentType as ChargeCategory,
r.CalculatedRate as UnitCost,
cr.unitCost as NIHRate,
--r.DayLease,

--case statement when dayeleaselength > 0 then dayleasr leanth else 1  as quantity
case
    when r.DayLeaseLength> 0 then r.dayleaseLength
    when r.researchowned = 'Yes' then 0
    when d.birthType = 'Born to Resource Dam' then 0
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

    When a.creditto is not null then 'Adjustment'
    When d.creditResource is not Null then d.creditResource
    Else 'p51'
    End as CreditTo,
Case

    when a.creditto is not null then a.creditto
    when d.creditResource is not Null then d.creditTo
    else ca.account
    End  as CreditAccount,
case
    WHen r.releaseType = 'No Charge' then 0
        WHen r.releaseType = 'IACUC Excluded / No Charge' then 0
    when r.researchOwned = 'Yes' then 0
    when r.DayLeaseLength> 0 then (r.dayleaseLength * r.CalculatedRate)
    --when r.revisedRate Is Not null then 2020
    when r.assignmentType = 'automatic_adjustment' and r.revisedrate > r.CalculatedRate then (r.revisedRate - r.CalculatedRate)
    when  r.assignmentType = 'automatic_adjustment' then ((r.CalculatedRate - r.RevisedRate) * -1)

    Else (1 * r.CalculatedRate)
    End as TotalCost,
r.calculatedRate,
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
	left outer join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeReleaseAdjustment a on a.id = r.id
    left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_Billing.chargeRates cr on r.chargeID = cr.chargeID and (cr.startDate <= r.date and cr.enddate >= r.date or cr.enddate is null)
    left outer join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.creditAccount ca on ca.chargeID = r.chargeID and (r.Date > ca.startDate and r.Date <= ca.enddate)
    Left outer join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFee_Demographics d on r.id = d.id and r.date = d.date and r.project = d.project