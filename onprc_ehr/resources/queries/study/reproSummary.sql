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
  t1.year,
  t1.monthname,
  t1.monthnum,
  t1.day,

  group_concat(t1.value, ', ') as value,

FROM (

SELECT
  t.id,
  t.date,
  'Menses' as category,
  'M' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study."Clinical Observations" t
WHERE t.category = 'Menses'

UNION ALL

SELECT
  t.id,
  t.date,
  'Delivery' as category,
  'D' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.delivery t

UNION ALL

SELECT
  t.id,
  t.date,
  'Pregnancies' as category,
  'P' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.pregnancyconfirmation t

UNION ALL

SELECT
  t.id,
  t.date,
  'Matings' as category,
  'Mating' as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.matings t

) t1

GROUP BY t1.year, t1.monthname, t1.monthnum, t1.day, t1.id
PIVOT value BY day