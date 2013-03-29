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
  year(c.date) as year,
  month(c.date) as monthNum,
  monthname(c.date) as month,
  c.eventType,
  c.value,
  count(*) as total

FROM study.clinicalEvents c
GROUP BY year(c.date), month(c.date), monthname(c.date), c.eventType, c.value