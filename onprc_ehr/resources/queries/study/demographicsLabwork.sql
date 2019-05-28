/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
  d.id,
  max(CASE WHEN h.type = 'Hematology' THEN h.date ELSE null END) as lastHematologyDate,
  TIMESTAMPDIFF('SQL_TSI_DAY',  max(CASE WHEN h.type = 'Hematology' THEN h.date ELSE null END), now()) as daysSinceCBCExam,

   max(CASE WHEN h.type = 'Biochemistry' THEN h.date ELSE null END) as lastBiochemistryDate  ,
   TIMESTAMPDIFF('SQL_TSI_DAY',  max(CASE WHEN h.type = 'Biochemistry' THEN h.date ELSE null END), now()) as daysSinceCHEMExam,

FROM study.demographics d
LEFT JOIN study.clinpathRuns h ON (d.id = h.id AND (h.type = 'Hematology' OR h.type = 'Biochemistry'))
WHERE d.calculated_status = 'Alive'
GROUP BY d.id

