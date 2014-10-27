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
  b.id,
  sum(b.quantity) as quantity,
  b.id.dataset.demographics.species.blood_draw_interval,
  cast(b.date as date) as date,
  timestampadd('SQL_TSI_DAY', b.id.dataset.demographics.species.blood_draw_interval, cast(b.date as date)) as dropDate
FROM study.blood b
--NOTE: this has been changed to include pending requests in the total
WHERE (b.countsAgainstVolume = true)
GROUP BY b.id, b.id.dataset.demographics.species.blood_draw_interval, cast(b.date as date)