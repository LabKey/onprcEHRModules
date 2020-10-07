SELECT t.id,
t.CenterProject,
t.alias,
a.aliasType,
a.aliastype.removesubsidy,
a.aliastype.CanRaiseFa,

t.leasetype,
t.assignmentdate,


t.chargeId,
r.chargeID.CanRaiseFA as Chargeid_CanRaiseFA,
t.RevisedChargeID,
--Cost for Original Lease, baswed on Projected release Type



 --for adjustments, this is the first lease charge


 --for adjustments, this is the second lease charge
--Review of Data relating to Alias and Charge Rate
--Is EWxempt

--Is Non Standard Rate


--lacks Rate


--Is accepting Charges
CASE
    WHEN a.aliasEnabled IS NULL THEN 'N'
    WHEN a.aliasEnabled != 'Y' THEN 'N'
    ELSE null
  END as isAcceptingCharges,

--Is Expired Account
CASE
    WHEN (a.budgetStartDate IS NOT NULL AND CAST(a.budgetStartDate as date) > CAST(t.assignmentdate as date)) THEN 'Prior To Budget Start'
    WHEN (a.budgetEndDate IS NOT NULL AND CAST(a.budgetEndDate as date) < CAST(t.assignmentdate as date)) THEN 'After Budget End'
    WHEN (a.projectStatus IS NOT NULL AND a.projectStatus != 'ACTIVE' AND a.projectStatus != 'No Cost Ext' AND a.projectStatus != 'Partial Setup') THEN 'Grant Project Not Active'
    ELSE null
  END as isExpiredAccount,
CASE WHEN a.alias IS NULL THEN 'Y' ELSE null END as isMissingAccount,
CASE WHEN a.fiscalAuthority.faid IS NULL THEN 'Y' ELSE null END as isMissingFaid,



FROM leaseFee_Test t,
"/ONPRC/ADMIN/FINANCE".onprc_billing.chargeRates r,
"/ONPRC/ADMIN/FINANCE".onprc_billing.aliases a,
"/ONPRC/ADMIN/FINANCE".onprc_billing_public.chargeRateExemptions e
where r.chargeId = t.chargeId and t.alias = a.alias
and(r.startDate <= t.assignmentdate and r.endDateCoalesced > t.assignmentdate)
and (CAST(t.assignmentDate AS DATE) >= CAST(e.startDate AS DATE)
and    (CAST(t.assignmentDate AS DATE) <= e.enddateCoalesced OR e.enddate IS NULL)
AND    t.chargeId = e.chargeId
AND   Cast(t.Centerproject as varchar(20)) = Cast(e.project as varchar(20)))