/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT rowid, category, activeRate.unitCost, itemCode + ' - ' + name as chargeName
FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.chargeableItems
WHERE category = 'Virology'
AND Active = 'true'