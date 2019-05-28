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
SELECT
  m.lsid,
  m.id,
  m.date,
  max(m.estDeliveryDate) as estDeliveryDate,
  group_concat(m.confirmationType.value) as confirmationType,
  count(distinct b.Id) as births,
  min(b.date) as birthDate,
  max(b.date) as maxBirthDate,
  group_concat(distinct b.id) as offspring,
  group_concat(distinct b.birth_condition) as birthCondition

FROM study.pregnancyConfirmation m
LEFT JOIN study.Birth b ON (b.dam = m.id AND m.date < b.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, b.date) < 180)
GROUP BY m.lsid, m.id, m.date