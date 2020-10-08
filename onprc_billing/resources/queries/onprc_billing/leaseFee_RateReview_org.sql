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
--Is Exemption review exemption and mulitpler
--Is Non Standard Rate
--Is Exemption
--Is Non Standard Rate
case
    When e.rowID is not null then 'Y'
    WHEN (rc.multiplier IS NOT NULL) THEN ('Multiplier: ' || CAST(rc.multiplier AS varchar(100)))
    ELSE null
    ENd as isExemption,
--Ie Manually Entered
--Is Adjustment/Reversal
---Missing Alias
--Alias Accepting Charges
--Expired Alias
-->45 Days Olde
--Is Assigned at Tom
--IS Assigned to Protocol at Time
--Ie Manually Entered
--Is Adjustment/Reversal
---Missing Alias


-->45 Days Olde
--Is Assigned at Tom
--IS Assigned to Protocol at Time
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



FROM Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leaseFee_RateData t
    left join
        Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.chargeRates r on r.chargeID = t.chargeID and t.alias = r.AliasAtTIme
    Left join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.aliases a on t.alias = a.alias
    Left Join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing_public.chargeRateExemptions e e.
    Left Join Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.leasefee_rateChargeItem rc

