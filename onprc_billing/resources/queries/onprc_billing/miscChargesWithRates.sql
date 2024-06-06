--Modified by Kollil  on 6/5/2024
--Removed the substitute paths for the billing containers to reference the onprc_billingPublic datasets and this change avoids user access to the Finance admin section.
SELECT
  p.Id,
  p.date,
  p.billingDate,
  p.project,
  COALESCE(p.debitedaccount, aliasAtTime.account) as account,
  p.chargetype,
  p.chargeId,
  COALESCE(p.chargetype.servicecenter, p.chargeId.departmentCode) as serviceCenter,
  coalesce(p.chargeId.name, p.item) as item,
  p.unitCost as MCEnteredUnitCost,
  case
    WHen p.unitCost is NOT NULL then p.unitCost
    When  RateCalc(p.debitedaccount,p.chargeID,p.project,p.Date,alias.farate)  Is Not Null then RateCalc(p.debitedaccount,p.chargeID,p.project,p.Date,alias.farate)
    Else cr.unitcost
  ENd as RateCalc,
  case
    WHen p.unitCost is NOT NULL then 'Misc Rate Entered'
    When  RateCalc(p.debitedaccount,p.chargeID,p.project,p.Date,alias.farate)  Is Not Null then 'Rate Calc Function'
    else 'Passed Thru to Cr UnitCost'
  ENd as RateMethod,
  round(CAST(CASE
    --order of priority for unit cost:
    --if this row specifies a unit cost, like an adjustment, defer to that.  this is unique to miscCharges
    --this occurs when the rate is a vairable rate or a reversal where an negative number is entered
    WHEN (p.unitCost IS NOT NULL) THEN p.unitCost
    --project-level exemption: pay this value
    WHEN (e.unitCost IS NOT NULL) THEN e.unitCost
    --project-level multiplier: multiply NIH rate by this value
    WHEN (pm.multiplier IS NOT NULL AND cr.unitCost IS NOT NULL) THEN (cr.unitCost * pm.multiplier)
    --if there is not a known rate, we dont know what do to
    WHEN (cr.unitCost IS NULL) THEN null
    --for non-OGA aliases, we always use the NIH rate
    WHEN (alias.category IS NOT NULL AND alias.category != 'OGA') THEN cr.unitCost
    --if we dont know the aliasType, we also dont know what do to
    WHEN (alias.aliasType.aliasType IS NULL) THEN null
   --remove both subsidy and raise F&A if needed
    WHEN (alias.aliasType.removeSubsidy = true AND (alias.aliasType.canRaiseFA = true AND p.chargeId.canRaiseFA = true)) THEN ((cr.unitCost / (1 - COALESCE(cr.subsidy, 0))) * (CASE WHEN (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)) THEN ((1 + (CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE) / (1 + alias.faRate)))) ELSE 1 END))
    --remove subsidy only
    WHEN (alias.aliasType.removeSubsidy = true AND alias.aliasType.canRaiseFA = false) THEN (cr.unitCost / (1 - COALESCE(cr.subsidy, 0)))
    --raise F&A on  ly
    WHEN (alias.aliasType.removeSubsidy = false AND (alias.aliasType.canRaiseFA = true AND p.chargeId.canRaiseFA = true)) THEN (cr.unitCost * (CASE WHEN (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)) THEN ((1 + (CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE)))/(1+ alias.faRate)) ELSE 1 END))
    --the NIH rate
    ELSE cr.unitCost
  END AS DOUBLE), 2) as unitCost,
  --note: when the row specifies a unit cost, we assume this is custom and lacking an NIH rate
  CASE WHEN (p.unitCost IS NOT NULL) THEN null ELSE cr.unitCost END as nihRate,
  coalesce(p.quantity, 1) as quantity,
  coalesce(p.category, p.chargeId.category) as category,
  p.chargeCategory,
  p.invoicedItemId,
  p.objectid as sourceRecord,
  p.comment,
  p.objectid,
  p.created,
  p.createdby,
  p.taskId,

  coalesce(p.creditedaccount, cu.account, ce.account) as creditAccount,
  CASE WHEN (cu.account IS NOT NULL) THEN 'Charge Unit' ELSE 'Chargeable Item' END as creditAccountType,
  null as creditAccountId,
  coalesce(alias.investigatorId, p.project.investigatorId) as investigatorId,
  CASE
    --dont flag adjustments/reversals as exceptions
    WHEN (p.chargeCategory = 'Reversal' OR p.chargeCategory LIKE 'Adjustment%') THEN null
    WHEN (p.unitCost IS NOT NULL OR e.unitCost IS NOT NULL) THEN 'Y'
    WHEN pm.multiplier IS NOT NULL THEN ('Multiplier: ' || CAST(pm.multiplier AS varchar(100)))
    ELSE null
  END as isExemption,
  CASE
    WHEN (p.unitCost IS NOT NULL) THEN null  --if this row specifies a unit cost, like reversals, dont cost as non-standard
    WHEN (e.unitCost IS NOT NULL) THEN null  --ignore project-level exemptions
    WHEN (pm.multiplier IS NOT NULL) THEN null --also ignore project-level multipliers
    WHEN (cr.unitCost IS NULL) THEN null --will be flagged for other reasons
    WHEN (alias.aliasType.aliasType IS NULL) THEN null --unknown alias type, will be flagged elsewhere
    WHEN (alias.aliasType.removeSubsidy = true AND COALESCE(cr.subsidy, 0) > 0) THEN 'Removed NIH Subsidy'
    WHEN (alias.aliasType.canRaiseFA = true AND p.chargeId.canRaiseFA = true AND (alias.faRate IS NOT NULL AND alias.faRate < CAST(javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.BASE_SUBSIDY') AS DOUBLE))) THEN ('Reduced F&A: ' || CAST(alias.faRate as varchar(20)))
    ELSE null
  END as isNonStandardRate,
  CASE WHEN (alias.alias IS NOT NULL AND alias.aliasType.aliasType IS NULL) THEN ('Unknown Type: ' || alias.aliasType) ELSE null END as isUnknownAliasType,
  CASE WHEN (p.chargeCategory = 'Reversal' OR p.chargeCategory LIKE 'Adjustment%') THEN 'Y' ELSE null END as isAdjustment,
  CASE
    WHEN (p.unitCost IS NULL AND e.unitCost IS NULL AND cr.unitCost IS NULL) THEN 'Y'
    ELSE null
  END as lacksRate,
  e.rowid as exemptionId,
  CASE WHEN e.rowid IS NULL THEN cr.rowid ELSE null END as rateId,

  --find assignment on this date
  CASE
    WHEN (p.project IS NULL AND p.debitedaccount IS NOT NULL) THEN null  --note: allow charges entered by account only
    WHEN p.project IS NULL THEN 'N'
    WHEN p.project.alwaysavailable = true THEN null
    WHEN (SELECT count(*) as projects FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a WHERE
      p.Id = a.Id AND
      (p.project = a.project OR p.project.protocol = a.project.protocol) AND
      (cast(p.date AS DATE) <= a.enddateCoalesced OR a.enddate IS NULL) AND
      cast(p.date as date) >= a.dateOnly
    ) > 0 THEN null
    ELSE 'N'
  END as matchesProject,
  (SELECT group_concat(distinct a.project.displayName, chr(10)) as projects FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.study.assignment a WHERE
    p.Id = a.Id AND
    (cast(p.date AS DATE) <= a.enddateCoalesced OR a.enddate IS NULL) AND
    cast(p.date as date) >= a.dateOnly
  ) as assignmentAtTime,
  p.container,
  CASE WHEN COALESCE(p.debitedaccount, aliasAtTime.account) IS NULL THEN 'Y' ELSE null END as isMissingAccount,
  CASE WHEN alias.fiscalAuthority.faid IS NULL THEN 'Y' ELSE null END as isMissingFaid,
  CASE
    WHEN alias.aliasEnabled IS NULL THEN 'N'
    WHEN alias.aliasEnabled != 'Y' THEN 'N'
    ELSE null
  END as isAcceptingCharges,
  CASE
    WHEN (alias.budgetStartDate IS NOT NULL AND CAST(alias.budgetStartDate as date) > CAST(p.date as date)) THEN 'Prior To Budget Start'
    WHEN (alias.budgetEndDate IS NOT NULL AND CAST(alias.budgetEndDate as date) < CAST(p.date as date)) THEN 'After Budget End'
    WHEN (alias.projectStatus IS NOT NULL AND alias.projectStatus != 'ACTIVE' AND alias.projectStatus != 'No Cost Ext' AND alias.projectStatus != 'Partial Setup') THEN 'Grant Project Not Active'
    ELSE null
  END as isExpiredAccount,
  CASE WHEN (TIMESTAMPDIFF('SQL_TSI_DAY', p.date, curdate()) > 45) THEN 'Y' ELSE null END as isOldCharge,
  p.project.account as currentActiveAlias,
  p.sourceInvoicedItem,
  p.invoiceId,
  CASE
    WHEN (p.debitedaccount IS NULL OR p.debitedaccount = aliasAtTime.account) THEN null
    ELSE 'Y'
  END as accountDiffersFromProject,
  true as isMiscCharge

FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_billing.miscCharges p

LEFT JOIN onprc_billing_public.chargeRates cr ON (
    CAST(p.date AS DATE) >= CAST(cr.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= cr.enddateCoalesced OR cr.enddate IS NULL) AND
    p.chargeId = cr.chargeId
)

LEFT JOIN onprc_billing_public.chargeRateExemptions e ON (
    CAST(p.date AS DATE) >= CAST(e.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= e.enddateCoalesced OR e.enddate IS NULL) AND
    p.chargeId = e.chargeId AND
    p.project = e.project
)

LEFT JOIN onprc_billing_public.creditAccount ce ON (
    CAST(p.date AS DATE) >= CAST(ce.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= ce.enddateCoalesced OR ce.enddate IS NULL) AND
    p.chargeId = ce.chargeId
)

LEFT JOIN onprc_billing_public.projectAccountHistory aliasAtTime ON (
  aliasAtTime.project = p.project AND
  aliasAtTime.startDate <= cast(p.date as date) AND
  aliasAtTime.endDate >= cast(p.date as date)
)

LEFT JOIN onprc_billing_public.aliases alias ON (
  alias.alias = COALESCE(p.debitedaccount, aliasAtTime.account) and alias.dateDisabled is Null
)

LEFT JOIN onprc_billing_public.projectMultipliers pm ON (
    CAST(p.date AS DATE) >= CASt(pm.startDate AS DATE) AND
    (CAST(p.date AS DATE) <= pm.enddateCoalesced OR pm.enddate IS NULL) AND
    alias.alias = pm.account
)

LEFT JOIN onprc_billing_public.chargeUnitAccounts cu ON (
  p.chargetype = cu.chargetype AND
  cast(cu.startDate AS date) <= cast(p.date as date) AND
  cast(cu.endDate AS date) >= cast(p.date as date)
)