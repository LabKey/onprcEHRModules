/*
 * Copyright (c) 2014 LabKey Corporation
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
  o.Id,
  o.date,
  o.category,
  o.area,
  o.observation,
  o.remark,
  o.caseid,
  c.category as caseCategory,
  c.isActive as caseIsActive,
  c.isOpen as caseIsOpen,
  o.taskid

FROM study.clinical_observations o
JOIN study.cases c ON (c.objectid = o.caseid)
WHERE (
  o.category IS NULL
  OR o.category NOT IN (javaConstant('org.labkey.ehr.EHRManager.OBS_REVIEWED'), javaConstant('org.labkey.ehr.EHRManager.VET_REVIEW'), javaConstant('org.labkey.ehr.EHRManager.VET_ATTENTION'))
)
AND o.taskid = (
  SELECT o2.taskid
  FROM study.clinical_observations o2
  WHERE o2.caseid = o.caseid AND o2.Id = o.Id AND o2.taskId is not null
  ORDER BY o2.date DESC LIMIT 1
)