-- Query to get ART core chargeable items
SELECT rowid, category, activeRate.unitCost, itemCode + ' - ' + name as chargeName
FROM "/onprc/admin/finance/public".onprc_billing_public.chargeableItems
WHERE category = 'ART Core'
  AND Active = 'true'