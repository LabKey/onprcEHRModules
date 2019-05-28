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
  ri.objectid as invoiceId,
  null as invoicedItemId,
  afc.objectid,
  null as sourceInvoicedItem,
  null as chargeType
from Af_Charges afc
left join Ref_ProjectsIACUC rpi on (afc.ProjectID = rpi.ProjectID)
left join Ref_FeesProcedures rfp on (afc.ProcedureID = rfp.ProcedureID)
left join (
  SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
  from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
  GROUP BY ri.objectid
) ri ON (afc.InvoiceNo >= ri.StartInvoice AND afc.InvoiceNo <= ri.EndInvoice)

where afc.ChargeType not in (1, 4, 8, 10) and ChargeDate >= '1/1/2008' and (AccountNo is null or AccountNo = '')
--blood now automatically calculated.  dont migrate draws after 1/1
and (rfp.ProcedureName != 'Blood Draw' OR (rfp.ProcedureName = 'Blood Draw' AND ChargeDate < '1/1/2014'))
and (afc.ts > ? or rpi.ts > ?  or rfp.ts > ? or ri.maxTs > ?)

UNION ALL

/*
Next get non-surgery adjustments
*/

select
  afc2.AnimalID as id,
  afc2.ChargeDate as date,
  afc2.ProjectID as project,
  afc2.OHSUAccountNo as account,
  --afc2.ChargeType as chargeType,
  (select s.value from sys_parameters s where afc2.ChargeType = s.Flag and s.Field = 'ChargeType') as category,
  afc2.ProcedureID as procedureID,
  rfp.ProcedureName as item,
  (select bci.rowId from Labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeID,
  afc2.ProcedureCount as quantity,
  afc2.Amount as rawunitCost,
  --(afc2.Amount * afc2.ProcedureCount) as totalCost,
  afc2.Remarks as comment,
  CASE WHEN (afc2.invoiceDate IS NOT NULL AND afc2.invoiceDate < afc2.billingDate) THEN afc2.invoiceDate ELSE afc2.BillingDate END as billingDate,
  afc2.InvoiceNo as invoiceNumber,
  ri.objectid as invoiceId,
  (SELECT MAX(cast(ibs.objectid as varchar(38))) FROM AF_ChargesIBS ibs WHERE afc2.AccountNo = cast(ibs.ChargesIDKey as varchar(100))) as invoicedItemId,
  afc2.objectid,
  null as sourceInvoicedItem,
  'Adjustment' as chargeType
from af_charges afc
left join AF_Charges afc2 on (cast(afc.IDKEY as varchar(100))= afc2.AccountNo)
left join Ref_ProjectsIACUC rpi on (afc2.ProjectID = rpi.ProjectID)
left join Ref_FeesProcedures rfp on (afc2.ProcedureID = rfp.ProcedureID)
left join (
  SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
  from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
  GROUP BY ri.objectid
) ri ON (afc.InvoiceNo >= ri.StartInvoice AND afc.InvoiceNo <= ri.EndInvoice)

where afc.ChargeType not in (4, 10) and afc2.AccountNo is not null and afc2.AccountNo <> ''
and afc.ChargeDate >= '1/1/2008' and afc2.ChargeDate >= '7/1/2012'
and (afc.ts > ? or afc2.ts > ? or rpi.ts > ?  or rfp.ts > ? or ri.maxTs > ?)

UNION ALL

/*
Next get surgery adjustments
*/

select
  afc2.AnimalID as id,
  afc2.ChargeDate as date,
  afc2.ProjectID as project,
  afc2.OHSUAccountNo as account,
  --afc2.ChargeType as chargeType,
  (select s.value from sys_parameters s where afc2.ChargeType = s.Flag and s.Field = 'ChargeType') as category,
  afc2.ProcedureID as procedureID,
  rsp.ProcedureName as description,
  (select bci.rowId from Labkey.onprc_billing.chargeableItems bci where rsp.ProcedureName = bci.name) as chargeID,
  afc2.ProcedureCount as quantity,
  afc2.Amount as rawunitCost,
  --(afc2.Amount * afc2.ProcedureCount) as totalCost,
  afc2.Remarks as comment,
  CASE WHEN (afc2.invoiceDate IS NOT NULL AND afc2.invoiceDate < afc2.billingDate) THEN afc2.invoiceDate ELSE afc2.BillingDate END as billingDate,
  afc2.InvoiceNo as invoiceNumber,
  ri.objectid as invoiceId,
  (SELECT MAX(cast(ibs.objectid as varchar(38))) FROM AF_ChargesIBS ibs WHERE afc2.AccountNo = cast(ibs.ChargesIDKey as varchar(100))) as invoicedItemId,
  afc2.objectid,
  null as sourceInvoicedItem,
  'Adjustment' as chargeType
from af_charges afc
left join AF_Charges afc2 on (cast(afc.IDKEY as varchar(100)) = afc2.AccountNo)
left join Ref_ProjectsIACUC rpi on (afc2.ProjectID = rpi.ProjectID)
left join Ref_SurgProcedure rsp on (afc2.ProcedureID = rsp.ProcedureID)
left join (
  SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
  from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
  GROUP BY ri.objectid
) ri ON (afc.InvoiceNo >= ri.StartInvoice AND afc.InvoiceNo <= ri.EndInvoice)

where afc.ChargeType in (4, 10) and afc2.AccountNo is not null and afc2.AccountNo <> ''
and afc.ChargeDate >= '1/1/2008'
and afc2.ChargeDate >= '7/1/2012'
and (afc.ts > ? or afc2.ts > ? or rpi.ts > ?  or rsp.ts > ? or ri.maxTs > ?)

UNION ALL

/*
Next get NHP per diem adjustments
*/

select
  afc.AnimalID as id,
  afc.ChargeDate as date,
  afc.ProjectID as project,
  afc.OHSUAccountNo as account,
  --afc.ChargeType as chargeType,
  (select s.value from sys_parameters s
  where afc.ChargeType = s.Flag and s.Field = 'ChargeType') as category,
  afc.ProcedureID as procedureID,
  rfp.ProcedureName as description,
  (select bci.rowId from Labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeID,
  afc.ProcedureCount as quantity,
  afc.Amount as rawunitCost,
  --(afc.Amount * afc.ProcedureCount) as totalCost,
  null as comment,
  CASE WHEN (afc.invoiceDate IS NOT NULL AND afc.invoiceDate < afc.billingDate) THEN afc.invoiceDate ELSE afc.BillingDate END as billingDate,
  afc.InvoiceNo as invoiceNumber,
  ri.objectid as invoiceId,
  null as invoicedItemId,
  afc.objectid,
  null as sourceInvoicedItem,
  'Adjustment' as chargeType
from Af_ChargesPerDiem afc
left join Ref_ProjectsIACUC rpi on (afc.ProjectID = rpi.ProjectID)
left join Ref_FeesProcedures rfp on (afc.ProcedureID = rfp.ProcedureID)
left join (
  SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
  from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
  GROUP BY ri.objectid
) ri ON (afc.InvoiceNo >= ri.StartInvoice AND afc.InvoiceNo <= ri.EndInvoice)
where afc.AccountNo is not null and afc.AccountNo <> '' and ChargeDate >= '1/1/2008'
and (afc.ts > ? or rpi.ts > ? or rfp.ts > ? or ri.maxTs > ?)

UNION ALL

Select
  afc.AnimalID as id,
  afc.chargeDate as date,
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
  ri.objectid as invoiceId,
  (SELECT MAX(cast(ibs.objectid as varchar(38))) FROM AF_ChargesIBS ibs WHERE afc.AccountNo = cast(ibs.ChargesIDKey as varchar(100))) as invoicedItemId,
  afc.objectid,
  null as sourceInvoicedItem,
  null as chargeType
from af_charges afc
--left join AF_Charges afc2 on (afc.IDKEY = afc2.AccountNo)
left join Ref_ProjectsIACUC rpi on (afc.ProjectID = rpi.ProjectID)
left join Ref_FeesProcedures rfp on (afc.ProcedureID = rfp.ProcedureID)
left join (
SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
  from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
  GROUP BY ri.objectid
) ri ON (afc.InvoiceNo >= ri.StartInvoice AND afc.InvoiceNo <= ri.EndInvoice)

where afc.ChargeType in (1,8) and
  (afc.Chargedate < afc.BillingDate AND (afc.AccountNo is null or afc.AccountNo = '') AND (
    --the intent of this is to capture any charge entered 1 billing period after the actual record
    DATEDIFF(day, afc.Chargedate, afc.BillingDate) > 15 OR
    CASE WHEN DAY(afc.Chargedate) <= 15 THEN 1 ELSE 2 END != CASE WHEN DAY(afc.BillingDate) <= 15 THEN 1 ELSE 2 END
  ))
and (afc.ts > ? or rpi.ts > ?  or rfp.ts > ? or ri.maxTs > ?)

) t

left join labkey.onprc_billing.chargeRates cr ON (cr.chargeId = t.chargeId and cr.startDate <= t.date AND coalesce(cr.enddate, CURRENT_TIMESTAMP) >= t.date)
left join labkey.onprc_billing.chargeRateExemptions cre ON (cre.chargeId = t.chargeId and cre.startDate <= t.date AND coalesce(cre.enddate, CURRENT_TIMESTAMP) >= t.date and cre.project = t.project)