--Corrested Issue with Adjustments and loading into Test
--20200111 - changed source from rate data to a passthru with a lookup of rate name and unit cost

SELECT d.Id,
       r.leasetype,
       d.ResearchOwned,
       d.project,  --integer
       d.project.name as CenterProject,
       r.AliasAtTime,
       d.AgeAtAssignment,
       d.ageinyears,
       d.AgeGroup,
       d.BirthAssignment,
       d.BirthType,
       d.AssignmentType,
       d.DayLease,
       d.DayLeaseLength, --integer
       d.MultipleAssignments,
       d.CreditResource as dualassignment,
       null as creditto,
       d.date,
       d.projectedRelease,
       d.enddate,
       d.datefinalized,
       d.assignCondition, --integer
       d.projectedReleaseCondition, --integer
       d.releaseCondition, --integer
       d.releaseType,
       d.remark,
       d.alias,
       d.farate,
       d.removesubsidy,
       d.canRaiseFA,
       r.ChargeID, --integer
       i.Name as Item,
       i.DepartmentCode as ServiceCenter,
       r.exemptionRate,
       r.Multiplier,
       r.subsidy,
       RateCalc(r.AliasAtTime,r.chargeID,d.project,d.Date,d.farate)  as CalculatedRate,
       null as revisedRate,
       r.revisedChargeID,
       r.revisedSubsidy

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_rateChargeItem r join
	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFee_Demographics d on r.id = d.id and r.assignmentdate = d.date and r.projectid = d.project
    join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_LeaseType t on d.id = t.id and t.assignmentdate = d.date and t.project = d.project
     join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeableItems i on i.rowID = r.chargeID

union

select
    a.id,
    'automatic_adjustment' as AssignmentType,
    '' as researchOwned,
    a.projectID, --intege
    a.project.name as CenterProject,
    a.alias,
    a.ageattime,
    1 as ageinYears, --need to run function to return years
    '' as agegroup,
    '' as BirthAssignment,
    '' as BirthType,
    'automatic_adjustment' as AssignmentTypeNA,
    '' as DayLease,
    '' as DayLeaseLength, --integer
    '' as MultipleAssignments,
       null as dualassignment,
       null as creditto,
    a.date,
    a.enddate as projectedrelease,
    a.enddate,
    a.datefinalized,
    a.assignCondition, --0integer
    a.projectedReleaseCondition, --integer
    a.releaseCondition,--integer
    a.releasetype,
    '' as remark,
    a.alias as alias2,
    a.faRate as farate,
    a.removeSubsidy as removesubsidy,
    a.canRaiseFA as canRaiseFA,
    a.leaseCharge1, --integer
    ii.name as Item,
    ii.DepartmentCode as ServiceCenter,
    null as exemptionRate,
     null as Multiplier,
     null as subsidy,
    RateCalc(a.alias,a.leasecharge1,a.projectID, a.date,a.farate) as CalculatedRate,
    RateCalc(a.alias,a.leasecharge2,a.projectID, a.date,a.farate) as RevisedRate,
    a.leaseCharge2,
    null as RevisedSubsidy

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFeeReleaseAdjustment a
join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeableItems ii on ii.rowID = a.chargeID


Union



Select
    r.id,
    'Misc Charge',
    null as researchOwned,
    r.project,
    r.project.name as CenterProject,
    r.account.alias,
    null as ageatTime,
    null as ageInYears,
    null as AgeGroup,
    null as BirthAssignment,
    null as BirthType,
    case
        When r.chargeCategory is not Null then r.chargeCategory
        Else     'Misc Charge'
        End as AssignmentTypeNA,
    null as DayLease,
    null as DayLeaseLength, --integer
    null as MultipleAssignments,
     null as dualassignment,
       null as creditto,
    r.date,
    null as projectedrelease,
    null as enddate,
    null as datefinalized,
    null as assignCondition, --0integer
    null as projectedReleaseCondition, --integer
    null as releaseCondition,--integer
    null as releasetype,
    r.comment as remark,
    null as alias2,
    null as farate,
    null as removesubsidy,
    null as canRaiseFA,
    r.chargeID, --integer
    r.chargeID.Name as Item,
     r.serviceCenter as ServiceCenter,
    null as exemptionRate,
    Null as Multiplier,
    null as Subsidy,

    r.rateCalc,
    null as RevisedRate,
    null as rate2,
    null as RevisedSubsidy



FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.miscChargesWithRates r
WHERE cast(r.billingDate as date) >= CAST(StartDate as date) AND cast(r.billingDate as date) <= CAST(EndDate as date)
AND r.category IN ('Lease Fees', 'Lease Setup Fee', 'Lease Setup Fees')
