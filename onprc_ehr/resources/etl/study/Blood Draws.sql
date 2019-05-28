/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
  cast(afb.AnimalID as nvarchar(4000)) as Id,
  Date as Date,
  ref1.projectId as project,
  CASE
  WHEN bd.NoChargeFlag = 1 THEN 'No Charge'
  ELSE null
  END as chargeType,

    Amount as quantity,
    DrawCount as needlesticks,

--	Investigator as Investigator  ,  ----- Ref_Investigator(InvestigatorID)
--		Ref.LastName as LastName,
--	IDKey as  IDKey, 

    s1.Value as Reason,
    --Reason as ReasonInt,

    afb.objectid,

    --blood data
    --bd.BloodIDKey as BloodIDkey,

    bd.InvestigatorId as InvestigatorId,   ----- Ref_Investigator(InvestigatorID)
    ref.LastName + ', ' + ref.FirstName as requestor,
    bd.NoChargeFlag as NoChargeFlag,       ------When Not to be billed transaction Flag = 1, When it is to be billed Flag = 0
    bd.BloodDrawFlag as BloodDrawFlag      ------When Blood Draw transaction Flag = 1, When injections Flag = 0


From Af_Blood Afb
LEFT JOIN Sys_Parameters s1 ON (Afb.Reason = s1.Flag And s1.Field = 'BloodReason')
LEFT JOIN Ref_Investigator ref ON (Afb.Investigator = ref.InvestigatorID)

LEFT JOIN Af_BloodData bd ON (bd.BloodIDKey = afb.IDKey)
LEFT JOIN Ref_Projectsiacuc ref1 ON (ref1.ProjectID = bd.ProjectId)
LEFT JOIN Ref_Investigator ref2 ON (ref2.InvestigatorId = bd.InvestigatorId)

WHERE (afb.ts > ? or bd.ts > ?)
