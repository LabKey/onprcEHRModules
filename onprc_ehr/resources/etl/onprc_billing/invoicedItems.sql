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
  OHSUAlias as creditedAccount,
  null as debitedaccount,
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
  OHSUAlias as creditedAccount,
  null as debitedaccount,
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