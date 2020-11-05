--Update to full path Source
PARAMETERS (StartDate TIMESTAMP, EndDate TIMESTAMP)

SELECT
a.id,
case
    When a.enddate < a.dateFinalized then a.dateFinalized
    Else a.enddate
    End as date,
--a.date,
a.project,
a.project.project as projectID,
a.project.account as alias,
a.project.account.farate as faRate,
a.project.account.aliastype.removesubsidy as removeSubsidy,
a.project.account.aliastype.canRaiseFA as CanRaiseFA,
a.project.account.investigatorID,
a.project.account.fiscalAuthorityName as FANAme,
a.date as assignmentStart,
a.enddate,
a.projectedReleaseCondition,
a.releaseCondition,
a.assignCondition,
a.releaseType,
a.ageAtTime.AgeAtTimeYearsRounded as ageAtTime,
a5.id as ESPFAnimal,
'Lease Fees' as category,
--////This selectes the charge ID to be used
(SELECT max(rowid) as rowid FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing_public.chargeableItems ci WHERE ci.name = javaConstant('org.labkey.onprc_billing.ONPRC_BillingManager.LEASE_FEE_ADJUSTMENT') and ci.active = true) as chargeId,
CASE
  when (fl.id Is Not Null) then 0
  when (d.researchOwned = 'yes') then 0
  else 1
  end as quantity,
lf2.chargeId as leaseCharge1,
lf.chargeId as leaseCharge2,
a.objectid as sourceRecord,
'Adjustment - Automatic' as chargeCategory,
'Y' as isAdjustment,
Case
	When a.id in (Select f.id from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.flags f where (f.id = a.id and f.flag.value = 'PI Purchased NHP' and f.enddate is Null)) then  'yes'
	else 'No'
    End as ResearchOwned,
a.datefinalized,
a.enddatefinalized


FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a
LEFT JOIN Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf
  ON (lf.assignCondition = a.assignCondition
    AND lf.releaseCondition = a.releaseCondition
    AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf.minAge OR lf.minAge IS NULL)
    AND (a.ageAtTime.AgeAtTimeYearsRounded < lf.maxAge OR lf.maxAge IS NULL)
      and (a.date >=lf.startDate
         and a.date <= lf.endDate)
  )

LEFT JOIN Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFeeDefinition lf2
  ON (lf2.assignCondition = a.assignCondition
    AND lf2.releaseCondition = a.projectedReleaseCondition
    AND (a.ageAtTime.AgeAtTimeYearsRounded >= lf2.minAge OR lf2.minAge IS NULL)
    AND (a.ageAtTime.AgeAtTimeYearsRounded < lf2.maxAge OR lf2.maxAge IS NULL)
    and (a.date >=lf2.startDate
         and a.date <= lf2.endDate)
  )

--find overlapping TMB at date of assignment
  LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a2 ON (
    a.id = a2.id AND a.project != a2.project
    AND a2.dateOnly <= a.dateOnly
    AND a2.endDateCoalesced >= a.dateOnly
    AND a2.project.name = javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TMB_PROJECT')
  )
LEFt join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.assignment_U42ESPF a5 on
  (  a.id = a5.id and a.project !=a5.project
    and a5.project = 1107
    and a5.dateonly <=a.dateOnly
     AND a5.endDateCoalesced >= a.dateOnly)

--adds the reasearch owned animal exemption
Left JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.flags fl on
    (a.id = fl.id
    and fl.flag.code = 4034
    and (a.date >= fl.date and a.date <=COALESCE(fl.enddate,Now()) ))

LEFt join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFee_demographics d
    on a.id = d.id

WHERE a.releaseCondition != a.projectedReleaseCondition
and (A.id != A5.id or A5.id is Null)
AND (a.enddatefinalized is not null)
and (a.enddateFinalized >= startDate and a.enddateFinalized <= enddate)
AND a.qcstate.publicdata = true
and lf.chargeID  is not null
--AND lf.active = true
AND a2.id IS NULL and a.participantID not like '[a-z]%'