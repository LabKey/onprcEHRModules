/*
 * Copyright (c) 2013-2014 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/*
First get new charges
*/

select
  t.*,
  CASE
    WHEN t.chargeType = 'Adjustment' THEN t.rawUnitCost
    WHEN t.rawUnitCost = cr.unitcost AND cre.rowId IS null THEN NULL
    WHEN t.rawUnitCost = cre.unitcost THEN NULL
    ELSE t.rawUnitCost
  END as unitcost

FROM (

select
  afc.AnimalID as id,
  afc.ChargeDate as date,
  afc.ProjectID as project,
  afc.OHSUAccountNo as account,
  --afc.ChargeType as chargeType,
  (select s.value from sys_parameters s where afc.ChargeType = s.Flag and s.Field = 'ChargeType') as category,
  afc.ProcedureID as procedureID,
  rfp.ProcedureName as item,
  (select bci.rowId from Labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeID,
  afc.ProcedureCount as quantity,
  afc.Amount as rawunitCost,
  --(afc.Amount * afc.ProcedureCount) as totalCost,
  afc.Remarks as comment,
  CASE WHEN (afc.invoiceDate IS NOT NULL AND afc.invoiceDate < afc.billingDate) THEN afc.invoiceDate ELSE afc.BillingDate END as billingDate,
  afc.InvoiceNo as invoiceNumber,
  null as invoicedItemId,
  afc.objectid,
  null as sourceInvoicedItem,
  null as chargeType
from Af_Charges afc
left join Ref_ProjectsIACUC rpi on (afc.ProjectID = rpi.ProjectID)
left join Ref_FeesProcedures rfp on (afc.ProcedureID = rfp.ProcedureID)

where afc.ChargeType not in (1, 4, 8, 10) and ChargeDate >= '1/1/2008' and (AccountNo is null or AccountNo = '')

--we have migrated more.  only migrate injections after 2014
and afc.BillingDate >= '1/1/2014' and rfp.ProcedureName = 'Injection'
and (afc.ts > ? or rpi.ts > ?  or rfp.ts > ?)

) t

left join labkey.onprc_billing.chargeRates cr ON (cr.chargeId = t.chargeId and cr.startDate <= t.date AND coalesce(cr.enddate, CURRENT_TIMESTAMP) >= t.date)
left join labkey.onprc_billing.chargeRateExemptions cre ON (cre.chargeId = t.chargeId and cre.startDate <= t.date AND coalesce(cre.enddate, CURRENT_TIMESTAMP) >= t.date and cre.project = t.project)