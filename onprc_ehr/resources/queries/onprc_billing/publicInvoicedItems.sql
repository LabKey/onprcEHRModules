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
SELECT
  i.rowId,
  i.invoiceId,
  i.transactionNumber,
  i.invoiceDate,
  i.Id,
  i.item,
  i.date,
  i.itemCode,
  i.category,
  i.servicecenter,
  i.project,
  i.debitedaccount,
  i.creditedaccount,
  i.faid,
  i.investigatorId,
  i.firstName,
  i.lastName,
  i.department,
  i.mailcode,
  i.contactPhone,
  i.chargeId,
  i.objectid,
  i.quantity,
  i.unitCost,
  i.totalcost

FROM onprc_billing.invoicedItems i
WHERE i.invoiceId.status = 'Finalized' AND (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da WHERE isMemberOf(da.userid) AND (
    da.allData = true OR
    (da.project = i.project) OR
    da.investigatorId = i.investigatorId
  )) IS NOT NULL OR isMemberOf(i.project.investigatorId.userid) OR isMemberOf(i.project.investigatorId.financialAnalyst)

