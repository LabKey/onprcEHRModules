/*
 * Copyright (c) 2013-2017 LabKey Corporation
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
  pvt.*,
  grp.isPregnant
FROM
  (SELECT
    t2.id,
    t2.year,
    t2.monthname,
    t2.monthnum,
    t2.day,
    group_concat(DISTINCT t2.value, chr(10)) as value,

  FROM study.reproSummaryRawData t2

  GROUP BY t2.year, t2.monthname, t2.monthnum, t2.day, t2.id
  PIVOT value BY day IN (SELECT value FROM ldk.integers i WHERE i.value > 0 AND i.value <=31 ORDER BY i.value)) pvt

  LEFT OUTER JOIN

  (SELECT
    group_concat(DISTINCT t2.isPregnant) as isPregnant,
    t2.id,
    t2.year,
    t2.monthname,
    t2.monthnum

    FROM study.reproSummaryRawData t2
    GROUP BY t2.year, t2.monthname, t2.monthnum, t2.id) grp

ON pvt.id = grp.id AND pvt.year = grp.year AND pvt.monthnum = grp.monthnum
