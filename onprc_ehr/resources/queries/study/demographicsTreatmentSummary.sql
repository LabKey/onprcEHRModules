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
  t1.id,
  t1.earliestClinicalMedication,
  TIMESTAMPDIFF('SQL_TSI_DAY', t1.earliestClinicalMedication, now()) as daysOnClinicalMedications
FROM (

SELECT
  d.Id,
  (select max(date) as lastDate FROM study."Treatment Orders" t WHERE d.Id = t.Id and t.isActive = true) as earliestClinicalMedication
FROM study.demographics d

) t1