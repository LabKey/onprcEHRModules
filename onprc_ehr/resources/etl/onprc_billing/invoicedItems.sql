/*
 * Copyright (c) 2013 LabKey Corporation
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
  ServiceCenter as category,
  TransactionType as transactionType,
  TransactionNumber as id,
  TransactionDate as date,
  TransactionDescription as item,
  LastName as lastName,
  FirstName as firstName,
  null as faid,
  Department as department,
  MailCode as mailCode,
  ContactPhone as contactPhone,
  ItemCode as ItemCode,
  Quantity as quantity,
  Price as unitCost,
  OHSUAlias as debitedAccount,
  null as creditedaccount,
  TotalAmount as totalCost,
  InvoiceDate as invoiceDate,
  InvoiceNumber as invoiceNumber,
  ProjectID as project,
  CageID as cageId,
  0 as credit,
  (select bci.rowId from labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeId,
  ci.objectid as objectid
from IRIS_Production.dbo.Af_Chargesibs ci
  left outer join IRIS_Production.dbo.Ref_FeesProcedures rfp
    on (ci.ItemCode = (Convert(varchar(6),rfp.ProcedureID) + 'C'))
    WHERE ItemCode not like '%C'
      and ci.FAID = ''
      and ci.ServiceCenter = 'PDAR'
      and ci.ts > ?

union all
--
-- PDAR debit entries - with FAID
--
SELECT
  ServiceCenter as category,
  TransactionType as transactionType,
  TransactionNumber as id,
  TransactionDate as date,
  TransactionDescription as item,
  LastName as lastName,
  FirstName as firstName,
  (select fa.rowid from labkey.onprc_billing.fiscalAuthorities fa where fa.faid like '%' + ci.faid + '%') as faid,
  Department as department,
  MailCode as mailCode,
  ContactPhone as contactPhone,
  ItemCode as ItemCode,
  Quantity as quantity,
  Price as unitCost,
  OHSUAlias as debitedAccount,
  null as creditedaccount,
  TotalAmount as totalCost,
  InvoiceDate as invoiceDate,
  InvoiceNumber as invoiceNumber,
  ProjectID as project,
  CageID as cageId,
  0 as credit,
  (select bci.rowId from labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeId,
  ci.objectid as objectid
from IRIS_Production.dbo.Af_Chargesibs ci
  left outer join IRIS_Production.dbo.Ref_FeesProcedures rfp
    on (ci.ItemCode = (Convert(varchar(6),rfp.ProcedureID) + 'C'))
  WHERE ItemCode not like '%C'
      and ci.FAID <> ''
      and ci.ServiceCenter = 'PDAR'
      and ci.ts > ?

union all
--
-- PSURG debit entries - with FAID
--
SELECT
  ServiceCenter as category,
  TransactionType as transactionType,
  TransactionNumber as id,
  TransactionDate as date,
  TransactionDescription as item,
  LastName as lastName,
  FirstName as firstName,
  (select fa.rowid from labkey.onprc_billing.fiscalAuthorities fa where fa.faid like '%' + ci.faid + '%') as faid,
  Department as department,
  MailCode as mailCode,
  ContactPhone as contactPhone,
  ItemCode as ItemCode,
  Quantity as quantity,
  Price as unitCost,
  OHSUAlias as debitedAccount,
  null as creditedaccount,
  TotalAmount as totalCost,
  InvoiceDate as invoiceDate,
  InvoiceNumber as invoiceNumber,
  ProjectID as project,
  CageID as cageId,
  0 as credit,
  (select bci.rowId from labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeId,
  ci.objectid as objectid
from IRIS_Production.dbo.Af_Chargesibs ci
  left outer join IRIS_Production.dbo.Ref_FeesProcedures rfp
    on (ci.ItemCode = (Convert(varchar(6),rfp.ProcedureID) + 'C'))
WHERE ItemCode not like '%C'
      and ci.FAID <> ''
      and ci.ServiceCenter = 'PSURG'
      and ci.ts > ?

union all
--
-- PDAR credit entries
--
SELECT
  ServiceCenter as category,
  TransactionType as transactionType,
  TransactionNumber as id,
  TransactionDate as date,
  TransactionDescription as item,
  LastName as lastName,
  FirstName as firstName,
  (select fa.rowid from labkey.onprc_billing.fiscalAuthorities fa where fa.faid like '%' + ci.faid + '%') as faid,
  Department as department,
  MailCode as mailCode,
  ContactPhone as contactPhone,
  ItemCode as ItemCode,
  Quantity as quantity,
  Price as unitCost,
  null as debitedaccount,
  OHSUAlias as creditedAccount,
  TotalAmount as totalCost,
  InvoiceDate as invoiceDate,
  InvoiceNumber as invoiceNumber,
  ProjectID as project,
  CageID as cageId,
  0 as credit,
  (select bci.rowId from labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeId,
  ci.objectid as objectid
from IRIS_Production.dbo.Af_Chargesibs ci
  left outer join IRIS_Production.dbo.Ref_FeesProcedures rfp
    on (ci.ItemCode = (Convert(varchar(6),rfp.ProcedureID) + 'C'))
WHERE ItemCode like '%C'
      and ci.FAID <> ''
      and ci.ServiceCenter = 'PDAR'
      and ci.ts > ?

union all
--
-- PSURG credit entries
--
SELECT
  ServiceCenter as category,
  TransactionType as transactionType,
  TransactionNumber as id,
  TransactionDate as date,
  TransactionDescription as item,
  LastName as lastName,
  FirstName as firstName,
  (select fa.rowid from labkey.onprc_billing.fiscalAuthorities fa where fa.faid like '%' + ci.faid + '%') as faid,
  Department as department,
  MailCode as mailCode,
  ContactPhone as contactPhone,
  ItemCode as ItemCode,
  Quantity as quantity,
  Price as unitCost,
  null as debitedaccount,
  OHSUAlias as creditedAccount,
  TotalAmount as totalCost,
  InvoiceDate as invoiceDate,
  InvoiceNumber as invoiceNumber,
  ProjectID as project,
  CageID as cageId,
  0 as credit,
  (select bci.rowId from labkey.onprc_billing.chargeableItems bci where rfp.ProcedureName = bci.name) as chargeId,
  ci.objectid as objectid
from IRIS_Production.dbo.Af_Chargesibs ci
  left outer join IRIS_Production.dbo.Ref_FeesProcedures rfp
    on (ci.ItemCode = (Convert(varchar(6),rfp.ProcedureID) + 'C'))
WHERE ItemCode like '%C'
      and ci.FAID <> ''
      and ci.ServiceCenter = 'PSURG'

and ci.ts > ?