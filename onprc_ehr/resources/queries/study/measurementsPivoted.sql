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
select
  m.id,
  m.date,
  m.category,
  m.tissue,
  group_concat(m.measurement, chr(10)) as value

FROM (

SELECT
  m0.Id,
  m0.date,
  m0.category,
  CASE
    WHEN m0.measurementNo IS NOT NULL THEN cast((m0.tissue || ' - ' || m0.measurementNo) as varchar(200))
    ELSE m0.tissue
  END as tissue,
  m0.measurement,
  m0.parentid

FROM (

SELECT
  m.Id,
  m.date,
  m.category,
  m.tissue.meaning as tissue,
  '1' as measurementNo,
  m.measurement1 as measurement,
  m.parentid

from study.measurements m
where measurement1 is not null

union all

select
  m.id,
  m.date,
  m.category,
  m.tissue.meaning as tissue,
  '2' as measurementNo,
  m.measurement2 as measurement,
  m.parentid

from study.measurements m
where measurement2 is not null

union all

select
  m.id,
  m.date,
  m.category,
  m.tissue.meaning as tissue,
  '3' as measurementNo,
  m.measurement3 as measurement,
  m.parentid

from study.measurements m
where measurement3 is not null

) m0

) m
group by m.id, m.date, m.category, m.tissue, m.parentid

pivot value by tissue
