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
  t.id,
  t.date,
  t.lastBloodDraw,
  t.quantity,
  --t.volReconstitutedPerDay,
  t.timeDiffWithLastBloodDraw,
  CASE
    WHEN ((t.quantity - (t.timeDiffWithLastBloodDraw * t.volReconstitutedPerDay)) < 0) THEN 0
    ELSE (t.quantity - (t.timeDiffWithLastBloodDraw * t.volReconstitutedPerDay))
  END as effectiveVolume,
  blood_per_kg,
  max_draw_pct,
  lastWeight

FROM (

SELECT
  bd.id,
  bd.date,
  max(bd.lastWeight) as lastWeight,
  max(bd.bloodDrawDate) lastBloodDraw,
  sum(bd.quantity) as quantity,
  max(volReconstitutedPerDay) as volReconstitutedPerDay,
  min(timeDiffWithBloodDraw) as timeDiffWithLastBloodDraw,
  max(blood_per_kg) as blood_per_kg,
  max(max_draw_pct) as max_draw_pct,

FROM study.currentBloodDraws bd
GROUP BY bd.id, bd.date

) t