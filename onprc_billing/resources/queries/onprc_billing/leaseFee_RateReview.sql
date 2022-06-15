SELECT r.id,
r.CenterProject,
r.ProjectID,
r.CurrentAlias,
r.AliasAtTime,
r.RemoveSubsidy,
r.leasetype,
r.assignmentdate,
r.code,
r.ProjectedReleaseCode,
r.AssignmentAge,
r.chargeId,
r.subsidy,
r.ChargeItem,
r.unitCost,
r.multiplier,
r.ExemptionRate,
r.RevisedChargeID,
r.RevisedItem,
r.RevisedSubsidy,
r.RevisedUnitCost,
Case
	when r.ExemptionRate is not null then ('Exemption Rate: ' || CAST(r.ExemptionRate AS varchar(100)))
	When r.multiplier is not null THEN ('Multiplier: ' || CAST(r.multiplier AS varchar(100)))
	Else Null
End as isExemption,
--Is Non Standard Rate  Looks to see if
--Ie Manually Entered
--Is Adjustment/Reversal

---Missing Alias
Case When r.aliasAtTime is Null then 'y'
	else 'n'
	End As Missingalias,
--Alias Accepting Charges
CASE
    WHEN a.aliasEnabled IS NULL THEN 'N'
    WHEN a.aliasEnabled != 'Y' THEN 'N'
    ELSE null
  END as isAcceptingCharges,
--Expired Alias
  CASE
    WHEN (a.budgetStartDate IS NOT NULL AND CAST(a.budgetStartDate as date) > CAST(r.assignmentdate as date)) THEN 'Prior To Budget Start'
    WHEN (a.budgetEndDate IS NOT NULL AND Cast(a.budgetEndDate as date ) < CAST(r.assignmentdate as date)) THEN 'After Budget End'
    WHEN (a.projectStatus IS NOT NULL AND a.projectStatus != 'ACTIVE' AND a.projectStatus != 'No Cost Ext' AND a.projectStatus != 'Partial Setup') THEN 'Grant Project Not Active'
    ELSE null
  END as isExpiredAccount,
-->45 Days Olde
CASE WHEN (TIMESTAMPDIFF('SQL_TSI_DAY', r.assignmentDate, curdate()) > 45) THEN 'Y' ELSE null END as isOldCharge
--Is Assigned at Time
--IS Assigned to Protocol at Time


FROM leasefee_rateChargeItem r
	Left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.aliases a on r.aliasatTime = a.alias