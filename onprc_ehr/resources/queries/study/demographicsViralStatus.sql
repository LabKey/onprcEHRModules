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
  d.Id,
  coalesce(t.viralStatus, 'Not SPF') as viralStatus,
  t.total

FROM study.demographics d
LEFT JOIN (
  SELECT
    f.Id,
    group_concat(distinct f.flag.value, chr(10)) as viralStatus,
    count(distinct f.flag.value) as total

  FROM study.flags f
  WHERE f.isActive = true AND f.flag.category = 'SPF' and f.id.dataset.demographics.calculated_status = 'Alive'

  GROUP BY f.id
) t ON (d.id = t.id)