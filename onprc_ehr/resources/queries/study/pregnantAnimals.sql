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
  d.id,
  max(p.date) as confirmationDate,
  max(p.estDeliveryDate) as estDeliveryDate,
  timestampdiff('SQL_TSI_DAY', curdate(), max(p.estDeliveryDate)) as estDeliveryDays,
  group_concat(p.confirmationType) as confirmationType

FROM study.demographics d
JOIN study.pregnancyOutcome p ON (p.id = d.Id)
WHERE p.birthDate IS NULL AND timestampdiff('SQL_TSI_DAY', p.date, curdate()) < 180
GROUP BY d.id