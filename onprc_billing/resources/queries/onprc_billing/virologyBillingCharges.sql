SELECT rowid, category, activeRate.unitCost, itemCode + ' - ' + name as chargeName
FROM "/onprc/admin/finance/public".onprc_billing_public.chargeableItems
WHERE category = 'Virology'
AND Active = 'true'