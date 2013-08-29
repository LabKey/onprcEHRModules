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
  p.Id,
  count(CASE WHEN p.category = 'Clinical' THEN 1 ELSE NULL END) as totalClinicalCases,
  count(CASE WHEN p.category = 'Behavior' THEN 1 ELSE NULL END) as totalBehaviorCases,
  count(CASE WHEN p.category = 'Surgery' THEN 1 ELSE NULL END) as totalSurgeryCases,
  count(*) as totalCases
FROM study.cases p
WHERE timestampdiff('SQL_TSI_DAY', p.date, now()) < 180
GROUP BY p.id