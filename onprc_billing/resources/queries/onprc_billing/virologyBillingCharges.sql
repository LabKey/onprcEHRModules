SELECT rowid, category, activeRate.unitCost, itemCode + ' - ' + name as chargeName
FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.chargeableItems
WHERE category = 'Virology'
AND Active = 'true'