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
  count(distinct pc.Id) as confirmations,
  min(pc.date) as confirmationDate,
  count(distinct b.Id) as births,
  min(b.date) as birthDate,
  max(b.date) as maxBirthDate,
  max(m.male) as male,
  group_concat(distinct b.id) as offspring,
  group_concat(distinct b.birth_condition) as birthCondition,

FROM study.matings m
LEFT JOIN study.pregnancyConfirmation pc ON (pc.id = m.id AND m.date < pc.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, pc.date) < 180)
LEFT JOIN study.Birth b ON (b.dam = m.id AND m.date < b.date AND TIMESTAMPDIFF('SQL_TSI_DAY', m.date, b.date) < 180)
GROUP BY m.lsid, m.id