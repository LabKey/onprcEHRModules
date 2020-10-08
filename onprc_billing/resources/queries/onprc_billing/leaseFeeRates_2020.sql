--Corrested Issue with Adjustments and loading into Test
--20200111 - changed source from rate data to a passthru with a lookup of rate name and unit cost

SELECT r.Id,
       r.leasetype,
       r.ResearchOwned,
      r.projectID,  --integer
       r.CenterProject,
       r.AliasAtTime,
       r.AgeAtTime as AgeAtAssignment,
       r.ageinyears,
       r.AgeGroup,
       r.BirthAssignment,
       r.BirthType,
       r.AssignmentType,
       r.DayLease,
       r.DayLeaseLength, --integer
       r.MultipleAssignments,
       r.CreditResource as dualassignment,
       r.creditto,
       r.assignmentdate,
       r.projectedRelease,
       r.releasedate,
       r.datefinalized,
       r.code as assignCondition, --integer
       r.ProjectedReleaseCode as projectedReleaseCondition, --integer
       r.releaseCondition, --integer
       r.releaseType,
       r.remark,
       r.Currentalias,
       r.farate,
      r.removesubsidy,
      r.canRaiseFA,
       r.ChargeID, --integer
       r.ChargeItem as Item,
       r.ServiceCenter,
       r.exemptionRate,
       r.Multiplier,
       r.subsidy,
       RateCalc(r.AliasAtTime,r.chargeID,r.projectID,r.assignmentDate,r.subsidy)  as CalculatedRate,
       null as revisedRate,
       r.revisedChargeID,
       r.revisedSubsidy

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_rateChargeItem r


union

select
    a.id,
    'automatic_adjustment' as AssignmentType,
    a.researchowned,
    a.projectID, --intege
    a.project.name as CenterProject,
    a.aliasAtTime,
    a.ageattime,
    1 as ageinYears, --need to run function to return years
    '' as agegroup,
    '' as BirthAssignment,
    '' as BirthType,
    'automatic_adjustment' as AssignmentTypeNA,
    '' as DayLease,
    1 as DayLeaseLength, --integer
    '' as MultipleAssignments,
       null as dualassignment,
    a.creditto,
    a.enddate as BillingDate,
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
    ii.activeRate.subsidy,
    case
        when a.dateFinalized < '5/1/2015' then 0
        when a.projectID = 1106 then 0
        When (a.removesubsidy = 'false' and a.canRaiseFa = 'false') then a.lf2rate
	    When (a.removesubsidy = 'true' or a.CanRaiseFa = 'true') then RateCalc(a.aliasAtTime,a.leasecharge1,a.projectID,a.assignmentStart,ii.activeRate.subsidy)
		When (a.removesubsidy = 'false' or a.CanRaiseFa = 'true') then RateCalc(a.aliasAtTime,a.leasecharge1,a.projectID,a.assignmentStart,ii.activeRate.subsidy)
		--Else RateCalc(a.aliasatTime,a.leasecharge2,a.projectID,a.enddate,ii.activeRate.subsidy)
		else a.lf2rate
       End as CalculatedRate,

     case
         when a.dateFinalized < '5/1/2015' then 0
         when a.projectID = 1106 then 0
         When (a.removesubsidy = 'false' or a.canRaiseFa = 'false') then a.lf2Rate


        Else RateCalc(a.aliasatTime,a.leasecharge2,a.projectID,a.enddate,a.subsidy)
       End as RevisedRate,
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
    r.removesubsidy,
    r.canRaiseFA,
    r.chargeID, --integer


    r.chargeID.Name as Item,
    r.serviceCenter as ServiceCenter,
    ' ' as IsExemption,
    --Cast(r.isExemption as Float) as IsExemption,
    r.PM_Multiplier,
    r.chargeID.activeRate.Subsidy as Subsidy,
    --' ' as Ratecalc,
    RateCalc(r.account,r.charge_ID,r.projectID,r.Date,r.subsidy) as CalculatedRate,
    null as RevisedRate,
    null as rate2,
    null as RevisedSubsidy



FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.miscChargesWithRates r
WHERE cast(r.billingDate as date) >= CAST(StartDate as date) AND cast(r.billingDate as date) <= CAST(EndDate as date)
AND r.category IN ('Lease Fees')