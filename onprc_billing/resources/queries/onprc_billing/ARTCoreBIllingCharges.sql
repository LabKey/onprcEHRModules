-- Query to get ART core chargeable items
SELECT rowid, category, activerate.unitCost, itemCode + ' - ' + name + '; Unit Cost - ' + CAST(activerate.unitCost as varchar) as chargeName
FROM "/onprc/admin/finance/public".onprc_billing_public.chargeableItems
WHERE category = 'ART Core'
AND Active = 'true'