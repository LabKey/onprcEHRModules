/*
 * Copyright (c) 2010-2014 LabKey Corporation
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
  t.lsid,
  t.id,
  t.date,
  cast(t.lastWeight as double) as lastWeight,
  t.lastWeightDate,
  cast(t.previousBlood as double) as previousBlood,
  cast((t.lastWeight * t.blood_per_kg * t.max_draw_pct) as double) as allowableBlood,
  cast(((t.lastWeight * t.blood_per_kg * t.max_draw_pct) - t.previousBlood) as double) as availableBlood,
  TIMESTAMPADD('SQL_TSI_DAY', (1 + (-1 * 21)), CAST(t.date AS DATE)) as minDate

FROM (

SELECT
  t0.*,
  --NOTE: this uses date part only
  (select avg(w2.weight) as lastWeight FROM study.weight w2 WHERE w2.id = t0.id AND w2.dateOnly = t0.lastWeightDate) as lastWeight
FROM (

SELECT
  b.lsid,
  b.id,
  b.quantity,
  b.dateOnly,
  b.date,
  b2.lastWeightDate,
  d.species.blood_per_kg,
  d.species.max_draw_pct,
  b3.quantity as previousBlood,
  b3.quantityWithoutPending as previousBloodWithoutPending
FROM study.demographics d
JOIN study."Blood Draws" b ON (d.id = b.id)
JOIN (
  SELECT
    b.lsid,
    --NOTE: this uses date part only
    max(w.dateOnly) as lastWeightDate
  FROM study.blood b
  JOIN study.weight w ON (w.id = b.id AND w.dateOnly <= b.dateOnly)
  GROUP BY b.lsid
) b2 on (b2.lsid = b.lsid)
JOIN (
  SELECT
    b1.lsid,
    --NOTE: this has been changed to include penidng/non-approved draws
    sum(b2.quantity) as quantity,
    sum(CASE WHEN (b2.countsAgainstVolume = true) THEN b2.quantity ELSE 0 END) as quantityWithoutPending,
  FROM study.blood b1
  JOIN study.blood b2 ON (b1.id = b2.id AND b2.dateOnly > TIMESTAMPADD('SQL_TSI_DAY', (-1 * 21), b1.dateOnly) AND b2.dateOnly <= b1.dateOnly)
  GROUP BY b1.lsid
) b3 ON (b3.lsid = b.lsid)
--NOTE: include all
--WHERE d.calculated_status = 'Alive'

) t0

) t