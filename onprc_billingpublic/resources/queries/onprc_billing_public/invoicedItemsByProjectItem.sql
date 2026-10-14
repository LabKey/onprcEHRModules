/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
  i.invoiceId,
  i.project,
  i.item,
  sum(i.quantity) as numItems,
  sum(i.totalCost) as total

FROM onprc_billing_public.publicInvoicedItems i

GROUP BY i.invoiceId, i.project, i.item