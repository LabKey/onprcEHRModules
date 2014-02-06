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
select
  'IRIS Legacy data' as comment,
  'Finalized' as status,
  max(ri2.RunDate) as runDate,
  ri.StartDate as billingPeriodStart,
  ri.EndDate as billingPeriodEnd,
  max(cast(ri.objectid as varchar(38))) as objectid,
  min(ri.StartInvoice) as invoiceNumber
from Ref_Invoice ri
left join ref_invoice ri2 ON (ri.startdate = ri2.startdate AND ri.enddate = ri2.enddate)
where (ri.ts > ? or ri2.ts > ?)
group by ri.startdate, ri.enddate
