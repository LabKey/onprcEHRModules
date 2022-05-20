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
 *Update 2022.05.03 change of source
 */
SELECT
    i.rowId,
    i.invoiceId,
    i.transactionNumber,
    i.date,
    i.invoiceDate,
    i.Id,
    i.item,
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
    i.totalcost,
    i.chargeCategory

FROM onprc_billing.invoicedItems i
 left join  pf_publicEhr.project pr on i.project = pr.project
left join pf_onprcehrPublic.investigators inv on inv.rowid = pr.investigatorid
left join pf_publicfinance.aliases a on a.alias = i.debitedaccount
left join pf_onprcehrPublic.investigators inv2 on inv2.rowid = a.investigatorid

where
i.date >= '2012-01-01'
and ((SELECT max(rowid) as expr
   FROM pf_publicFinance.dataAccess da
   WHERE isMemberOf(da.userid)
     AND (
               da.allData = true OR
               (da.project = i.project) OR
           --TODO: this needs to get cleaned up
               (
                           da.investigatorId = i.investigatorId
                       OR da.investigatorId = a.investigatorId
                   )
       )) IS NOT NULL
 )

--arbitrary cutoff to avoid problems in legacy data
AND i.date >= '2013-01-01'