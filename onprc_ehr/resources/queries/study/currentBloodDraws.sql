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
PARAMETERS(DATE_INTERVAL INTEGER, MAX_DRAW_PCT DOUBLE, ML_PER_KG DOUBLE)

SELECT
t.id,
t.date,
cast(t.quantity as double) as quantity,
t.species,
ML_PER_KG,
DATE_INTERVAL,
MAX_DRAW_PCT,
t.mostRecentWeight,
t.mostRecentWeightDate,
cast(t.allowableBlood as double) as maxAllowableBlood,
cast(t.bloodPrevious as double) as bloodPrevious,
cast((t.allowableBlood - t.bloodPrevious) as double) as allowablePrevious,

cast(t.bloodFuture as double) as bloodFuture,
cast((t.allowableBlood - t.bloodFuture) as double) as allowableFuture,

--if the draw is historic, always consider previous draws only.
--otherwise, look both forward and backwards, then take the interval with the highest volume
cast(case
  WHEN t.date < curdate() THEN (t.allowableBlood - t.bloodPrevious)
  WHEN t.bloodPrevious < t.bloodFuture THEN (t.allowableBlood - t.bloodFuture)
  ELSE (t.allowableBlood - t.bloodPrevious)
end  as double) as allowableBlood

FROM (

SELECT
  bd.id,
  bd.dateOnly as date,
  bd.quantity,
  d.species,
  d.id.mostRecentWeight.MostRecentWeight,
  d.id.mostRecentWeight.MostRecentWeightDate,
  (d.id.mostRecentWeight.MostRecentWeight * ML_PER_KG * MAX_DRAW_PCT) as allowableBlood,
  timestampadd('SQL_TSI_DAY', (-1 * DATE_INTERVAL), bd.dateOnly) as minDate,
  timestampadd('SQL_TSI_DAY', DATE_INTERVAL, bd.dateOnly) as maxDate,
  COALESCE(
    (SELECT
      SUM(coalesce(draws.quantity, 0)) AS _expr
    FROM study."Blood Draws" draws
    WHERE draws.id = bd.id
      AND draws.date > TIMESTAMPADD('SQL_TSI_DAY', (-1 * DATE_INTERVAL), bd.dateOnly)
      AND draws.dateOnly <= bd.dateOnly
      AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
  ), 0) AS BloodPrevious,
  COALESCE(
    (SELECT
      SUM(coalesce(draws.quantity, 0)) AS _expr
    FROM study."Blood Draws" draws
    WHERE draws.id = bd.id
      AND draws.date < TIMESTAMPADD('SQL_TSI_DAY', DATE_INTERVAL, bd.dateOnly)
      AND draws.dateOnly >= bd.dateOnly
      AND (draws.qcstate.metadata.DraftData = true OR draws.qcstate.publicdata = true)
  ), 0) AS BloodFuture

FROM (
  --find the relevant blood draws, total blood drawn per day, over the relevant time window
  SELECT
    b.id,
    b.dateOnly,
    sum(b.quantity) as quantity

  FROM (
    --find all blood draws within the interval, looking backwards
    SELECT
      b.id,
      b.dateOnly,
      b.quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

    UNION ALL

    --join 1 row for the current date
    SELECT
      d.id,
      curdate() as dateOnly,
      0 as quantity,
    FROM study.demographics d
    WHERE d.calculated_status = 'Alive'

    UNION ALL

    --add one row for each date when the draw drops off the record
    SELECT
      b.id,
      timestampadd('SQL_TSI_DAY', DATE_INTERVAL + 1, b.dateOnly),
      0 as quantity,
    FROM study.blood b
    WHERE b.dateOnly >= timestampadd('SQL_TSI_DAY', -1 * DATE_INTERVAL, curdate())

  ) b

  GROUP BY b.id, b.dateOnly

) bd

LEFT JOIN study.demographics d ON (d.id = bd.id)

) t