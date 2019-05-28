/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
--  Created: 1-3-2017 R.Blasa
SELECT
  t.Id,


  count(t.Id) as totalTreatmentsGiven,
  COUNT(CASE WHEN t.category = 'Behavior' THEN 1 ELSE null END) as totalBehaviorTreatmentsGiven,
   COUNT(CASE WHEN t.category = 'Clinical' THEN 1 ELSE null END) as totalClinicalTreatmentsGiven,
   COUNT(CASE WHEN t.category = 'Surgical' THEN 1 ELSE null END) as totalSurgicalTreatmentsGiven,


  GROUP_CONCAT(t.code.meaning, chr(10)) as activeTreatments,




FROM study.drug t
WHERE  (t.enddate is null or t.enddate >= now())

GROUP BY t.Id