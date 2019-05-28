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
  count(t.Id) as totalTreatments,
  COUNT(CASE WHEN t.category = 'Clinical' THEN 1 ELSE null END) as totalClinicalTreatments,
  COUNT(CASE WHEN t.category = 'Surgical' THEN 1 ELSE null END) as totalSurgicalTreatments,
  COUNT(CASE WHEN t.category = 'Research' THEN 1 ELSE null END) as totalResearchTreatments,

  GROUP_CONCAT(t.code.meaning, chr(10)) as activeTreatments,
  GROUP_CONCAT(CASE WHEN t.category = 'Clinical' THEN t.code.meaning ELSE null END, chr(10)) as clinicalTreatments,
  GROUP_CONCAT(CASE WHEN t.category = 'Surgical' THEN t.code.meaning ELSE null END, chr(10)) as surgicalTreatments,
  GROUP_CONCAT(CASE WHEN t.category = 'Research' THEN t.code.meaning ELSE null END, chr(10)) as researchTreatments,

  max(t.modified) as lastModification,

FROM study.treatment_order t
WHERE t.isActive = true
GROUP BY t.Id