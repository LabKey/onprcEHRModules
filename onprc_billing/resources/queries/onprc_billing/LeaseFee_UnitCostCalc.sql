SELECT d.Id,
       r.leasetype,
       d.ResearchOwned,
       d.project,  --integer
       d.ProjectAlias,
       d.AgeAtAssignment,
       d.ageinyears,
       d.AgeGroup,
       d.BirthAssignment,
       d.BirthType,
       d.AssignmentType,
       d.DayLease,
       d.DayLeaseLength, --integer
       d.MultipleAssignments,
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
       RateCalc(d.alias,r.chargeID,d.project,d.Date,d.farate)  as CalculatedRate,
       r.revisedChargeID

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_rateData r join
	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFee_Demographics d on r.id = d.id and r.assignmentdate = d.date and 		r.projectid = d.project
    join	Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_LeaseType t on d.id = t.id and t.assignmentdate = d.date and t.project = d.project


union

select
    a.id,
    'automatic_adjustment' as AssignmentType,
    '' as researchOwned,
    a.projectID, --intege
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
    ' ' as CalculatedRate,
    a.leaseCharge2

FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.LeaseFeeReleaseAdjustment a