-- Query to get ART core chargeable items
SELECT rowid, category, activerate.unitCost, itemCode + ' - ' + name + '; Unit Cost - ' + CAST(activerate.unitCost as varchar) as chargeName
FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.chargeableItems  -- Changed by kolli, 5/5/22
-- FROM "/onprc/admin/finance/public".onprc_billing_public.chargeableItems
WHERE category = 'ART Core'
AND Active = 'true'