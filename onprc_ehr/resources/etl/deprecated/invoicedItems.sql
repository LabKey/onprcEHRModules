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
--
-- PDAR debit entries - missing FAID
--
SELECT
	t.*,
	(select max(bci.rowId) from labkey.onprc_billing.chargeableItems bci where t.item = bci.name) as chargeId
FROM (
SELECT
  ri.objectid as invoiceId,
  CASE
	  WHEN (ci.ServiceCenter = 'PDAR' OR ci.ServiceCenter = 'SLAU') THEN rfp.ProcedureName
	  WHEN ci.ServiceCenter = 'PSURG' THEN sp.ProcedureName
    ELSE 'ERROR'
  END as item,
  CASE
	  WHEN sys.Value IS NOT NULL THEN sys.value
	  WHEN ci.ServiceCenter = 'PSURG' THEN 'Surgery'
	  ELSE null
  END as category,

  ci.objectid as objectid,
  inves.investigatorId as investigatorId,
  ci.ServiceCenter as ServiceCenter,
  ci.TransactionType as transactionType,
  ci.TransactionNumber as transactionNumber,
  ci.TransactionDate as date,
  CASE
	WHEN (LEN(ci.TransactionDescription) = 5) and ISNUMERIC(ci.TransactionDescription) = 1 THEN ci.TransactionDescription
	WHEN (ci.TransactionDescription IS NOT NULL and ISNUMERIC(substring(ci.TransactionDescription, 1, 5)) = 1) THEN substring(ci.TransactionDescription, 1, 5)
	ELSE null
  END as id,
  CASE
	WHEN (LEN(ci.TransactionDescription) = 5) and ISNUMERIC(ci.TransactionDescription) = 1 THEN null
	WHEN (ci.TransactionDescription IS NOT NULL and ISNUMERIC(substring(ci.TransactionDescription, 1, 5)) = 1) THEN ltrim(substring(ci.TransactionDescription, 6, LEN(ci.TransactionDescription)))
	ELSE ci.TransactionDescription
  END as comment,

  ci.LastName as lastName,
  ci.FirstName as firstName,
  CASE
  WHEN (ci.faid IS NULL or ci.faid = '') THEN null
  ELSE (select fa.rowid from labkey.onprc_billing.fiscalAuthorities fa where fa.faid like '%' + ci.faid + '%')
  END as faid,
  ci.Department as department,
  ci.MailCode as mailCode,
  ci.ContactPhone as contactPhone,
  ci.ItemCode as ItemCode,
  ci.Quantity as quantity,
  ci.Price as unitCost,
  ci.OHSUAlias as debitedAccount,
  ci2.OHSUAlias as creditedaccount,
  ci.TotalAmount as totalCost,
  ci.InvoiceDate as invoiceDate,
  ci.InvoiceNumber as invoiceNumber,
  ci.ProjectID as project,
  ci.CageID as cageId,
  null as credit
from Af_Chargesibs ci

--find corresponding debit
  left join Af_Chargesibs ci2 ON (ci2.ChargesIDKey = ci.ChargesIDKey AND ci.TransactionNumber = ci2.TransactionNumber AND ci.IDKey != ci2.IDKey)

--used to find the chargeid
  left join Ref_FeesProcedures rfp on (ci.ItemCode = (Convert(varchar(10),rfp.ProcedureID)) AND (ci.ServiceCenter = 'PDAR' OR ci.servicecenter = 'SLAU'))

  left join Ref_SurgProcedure sp on (ci.ItemCode = (Convert(varchar(10), sp.ProcedureID)) AND ci.ServiceCenter = 'PSURG')
  left join Sys_Parameters sys on (sys.Field = 'ChargeType' and sys.Flag = rfp.ChargeType)

  LEFT JOIN (
    select max(i.rowid) as investigatorId, lastName, firstName
    from labkey.onprc_ehr.investigators i
    group by i.LastName, i.firstname
    having count(*) <= 1
  ) inves ON (inves.firstname = ci.firstname and inves.lastname = ci.lastname)

  left join (
    SELECT max(ri.ts) as maxTs, max(cast(ri2.objectid as varchar(38))) as objectid, max(ri.StartInvoice) as StartInvoice, max(ri.EndInvoice) as EndInvoice
    from ref_invoice ri
    left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
    GROUP BY ri.objectid
  ) ri ON (ci.InvoiceNumber >= ri.StartInvoice AND ci.InvoiceNumber <= ri.EndInvoice)

WHERE ci.ItemCode not like '%C'
and (ci.ts > ? or ci2.ts > ? or rfp.ts > ? or sp.ts > ?)  --Note: removing or ri.maxTs > ?, as this is very slow and no strictly necessary at this point since we have migrated most data

) t

