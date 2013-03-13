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
  p.id,
  p.date,
  'Problem Created' as eventType,
  p.category as value,
  p.remark
FROM study.problem p

UNION ALL

SELECT
  c.id,
  c.date,
  'Case Opened' as eventType,
  c.category as value,
  c.remark
FROM study.cases c

UNION ALL

SELECT
  c.id,
  c.date,
  'Death - Not For Experiment' as eventType,
  c.cause as value,
  c.remark
FROM study.deaths c
WHERE c.cause != 'Sacrifice for Experiment'

UNION ALL

SELECT
  c.id,
  c.date,
  'Death - For Experiment' as eventType,
  c.cause as value,
  c.remark
FROM study.deaths c
WHERE c.cause = 'Sacrifice for Experiment'

UNION ALL

SELECT
  c.id,
  c.date,
  'Birth' as eventType,
  c.cond as value,
  c.remark
FROM study.birth c

UNION ALL

SELECT
  c.id,
  c.date,
  'Acquisition' as eventType,
  c.acquisitionType.value as value,
  c.remark
FROM study.arrival c

UNION ALL

SELECT
  c.id,
  c.date,
  'Departure' as eventType,
  c.destination as value,
  c.remark
FROM study.departure c