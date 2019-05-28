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
  t2.id,
  t2.year,
  t2.monthname,
  t2.monthnum @hidden,
  t2.day,
  CASE
    WHEN p.id IS NOT NULL THEN 'P'
    ELSE null
  END as isPregnant,
  t2.value,

FROM (

SELECT
  t1.id,
  t1.year,
  t1.monthname,
  t1.monthnum @hidden,
  t1.day,
  t1.value,
  CAST(cast(t1.year as varchar) || '-' || cast(t1.monthNum as varchar) || '-' || '01' as date) as mindate,
  TIMESTAMPADD('SQL_TSI_MONTH', 1, CAST(cast(t1.year as varchar) || '-' || cast(t1.monthNum as varchar) || '-' || '01' as date)) as maxdate,

FROM (

SELECT
  t.id,
  t.date,
  'Menses' as category,
  t.observation as value,

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
  substring(t.deliveryType.value, 1, 1) as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.delivery t

-- UNION ALL
--
-- SELECT
--   t.id,
--   t.date,
--   'Pregnancies' as category,
--   'Pregnancy' as value,
--
--   convert(year(t.date), integer) as year,
--   monthname(t.date) AS monthname,
--   convert(month(t.date), integer) AS monthnum,
--   convert(dayofmonth(t.date), integer) as day,
--
-- FROM study.pregnancyconfirmation t

UNION ALL

SELECT
  t.id,
  TIMESTAMPADD('SQL_TSI_DAY', i.value, t.date) as date,
  'Matings' as category,
  CASE
    WHEN t.matingType.value = 'Timed Mating' THEN 'T'
    ELSE '*'
  END as value,

  convert(year(t.date), integer) as year,
  monthname(t.date) AS monthname,
  convert(month(t.date), integer) AS monthnum,
  convert(dayofmonth(t.date), integer) as day,

FROM study.matings t
LEFT JOIN ldk.integers i ON (i.value <= TIMESTAMPDIFF('SQL_TSI_DAY', t.date, COALESCE(t.enddate, t.date)))

) t1

) t2

LEFT JOIN study.pregnancyOutcome p ON (p.id = t2.id and p.birthDate is not null AND
  (p.date <= t2.maxDate AND p.birthDate >= t2.minDate)
)
