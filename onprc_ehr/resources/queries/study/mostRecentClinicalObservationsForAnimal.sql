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
  t.Id,
  max(t.date) as date,

  GROUP_CONCAT(CASE
    WHEN (t.category IS NOT NULL AND t.area IS NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.observation || t.remark) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.area IS NOT NULL AND t.observation IS NOT NULL) THEN cast((t.category || ': ' || t.area || ', ' || t.observation) as varchar(1000))
    WHEN (t.category IS NOT NULL AND t.observation IS NULL) THEN cast((t.category || t.remark) as varchar(1000))
    WHEN (t.category IS NULL AND t.observation IS NOT NULL) THEN cast((t.observation || t.remark) as varchar(1000))
    else t.remark
  END, chr(10)) as observations

FROM (SELECT
  o.Id,
  o.date,
  CASE
    WHEN o.category = javaConstant('org.labkey.ehr.EHRManager.OBS_CATEGORY_OBSERVATIONS') THEN null
    ELSE o.category
  END as category,
  CASE
    WHEN o.area = 'N/A' THEN null
    ELSE o.area
  END as area,
  o.observation,
  COALESCE(CASE
    WHEN (o.remark IS NOT NULL AND o.observation IS NOT NULL) THEN ('.  ' || o.remark)
    ELSE o.remark
  END, '') as remark

FROM study.clinical_observations o
JOIN (
  SELECT o2.Id, max(o2.date) as date
  FROM study.clinical_observations o2
  WHERE o2.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
    AND o2.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
    AND (
      o2.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalRoundsFormType.NAME') OR
      o2.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalReportFormType.NAME')
    )
  GROUP BY o2.Id
) t ON (t.Id = o.Id AND t.date = o.date)

WHERE o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.VET_REVIEW')
  AND o.category != javaConstant('org.labkey.onprc_ehr.ONPRC_EHRManager.TECH_REVIEW')
  AND (
    o.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalRoundsFormType.NAME') OR
    o.taskId.formtype = javaConstant('org.labkey.onprc_ehr.dataentry.ClinicalReportFormType.NAME')
  )
) t
GROUP BY t.Id