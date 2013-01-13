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
  t.*,
  s.blood_draw_interval,
  s.blood_per_kg,
  s.max_draw_pct,
  (s.blood_per_kg / s.blood_draw_interval) as volReconstitutedPerDay,

  CASE
    WHEN ((s.blood_per_kg / s.blood_draw_interval) * abs(timeDiffWithBloodDraw) > t.quantity) THEN t.quantity
    ELSE ((s.blood_per_kg / s.blood_draw_interval) * abs(timeDiffWithBloodDraw))
  END as reconstituted,

FROM (

  SELECT
    b.id,
    dates.date,
    timestampdiff('SQL_TSI_DAY', curdate(), dates.date) as timeDiffWithNow,
    b.dateOnly as bloodDrawDate,
    timestampdiff('SQL_TSI_DAY', b.dateOnly, dates.date) as timeDiffWithBloodDraw,

    sum(b.quantity) as quantity,
    b.id.dataset.demographics.species,
    b.id.mostRecentWeight.MostRecentWeight as lastWeight,

  FROM (
    SELECT
      timestampadd('SQL_TSI_DAY', i.value, curdate()) as date,
    FROM ldk.integers i

    WHERE i.value < 30

  ) dates

  JOIN study.blood b ON (
    b.id.dataset.demographics.species.blood_draw_interval IS NOT NULL AND
    b.dateOnly <= dates.date AND
    timestampdiff('SQL_TSI_DAY', b.dateOnly, dates.date) <= b.id.dataset.demographics.species.blood_draw_interval
    --AND (b.qcstate.metadata.DraftData = true OR b.qcstate.publicdata = true)
  )

  GROUP BY b.id, b.dateOnly, dates.date, b.id.dataset.demographics.species, b.id.MostRecentWeight.MostRecentWeight

) t

LEFT JOIN ehr_lookups.species s ON (s.common = t.species)