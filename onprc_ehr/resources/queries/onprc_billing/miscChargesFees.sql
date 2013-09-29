/*
 * Copyright (c) 2013 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

PARAMETERS(EndDate TIMESTAMP)

SELECT
  mc.Id,
  mc.date,
  mc.project,
  mc.chargeId,
  mc.quantity,
  mc.unitCost,
  mc.totalCost,
  mc.category,
  mc.chargeType,
  mc.invoicedItemId,
  mc.objectid as sourceRecord,
  mc.comment

FROM onprc_billing.miscCharges mc

--we want to capture any unclaimed items from this table prior to the end of the billing period
WHERE mc.dateOnly <= CAST(EndDate as date) AND mc.invoiceId IS NULL