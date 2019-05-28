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
  m1.id,
  'f' as gender,
  m1.date,
  m1.daysElapsed,
  m1.enddate,
  m1.male as partner,
  'm' as partnerGender,
  m1.matingType,
  m1.outcome.confirmations as confirmations,
  m1.outcome.births as births,
  m1.outcome.offspring as offspring,
  m1.outcome.birthDate as birthDate,
  m1.outcome.birthCondition as birthCondition,
  m1.performedby,
  m1.remark

FROM study.matings m1

UNION ALL

SELECT
  m2.male,
  'm' as gender,
  m2.date,
  m2.daysElapsed,
  m2.enddate,
  m2.id as partner,
  'f' as partnerGender,
  m2.matingType,
  m2.outcome.confirmations as confirmations,
  m2.outcome.births as births,
  m2.outcome.offspring as offspring,
  m2.outcome.birthDate as birthDate,
  m2.outcome.birthCondition as birthCondition,
  m2.performedby,
  m2.remark

FROM study.matings m2

