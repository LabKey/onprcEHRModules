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
Select
  cast(td.AnimalID as varchar(4000)) as Id,
  td.Date,
  s3.Value as Origination,

  (select rowid from labkey.onprc_ehr.customers r where r.objectid = tr.objectid) as recipient,
--ptd.Recipient,						--Ref_TissueRecipients
  ptd.Organ as tissue,							--Ref_Snomed
  sno.Description as tissueMeaning,
--ptd.Affiliation as AffiliationInt,
  s1.Value as requestCategory,
--Sample as SampleInt,
  s2.Value as sampleType,

  ptd.objectid

From Path_TissueDistributions td
  left join Path_TissueDetails ptd on (td.tissueId = ptd.tissueid)
  left join Sys_Parameters s1 on (s1.Field = 'TissueAffiliation' and ptd.Affiliation = s1.Flag)
  left join Sys_Parameters s2 on (s2.Field = 'TissueSample' and ptd.Sample = s2.Flag)
  left join Sys_Parameters s3 on (s3.flag = td.Origination And s3.Field = 'TissueOrigination' )
  left join ref_snomed sno on (sno.SnomedCode = ptd.organ)
  left join Ref_TissueRecipients tr ON (tr.recipientId = ptd.recipient)

WHERE (ptd.ts > ? or td.ts > ?)

