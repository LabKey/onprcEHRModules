/*
 * Copyright (c) 2014-2017 LabKey Corporation
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
PARAMETERS(ID CHAR)

SELECT
  pvt.*,
  grp.isPregnant
FROM
  (SELECT
    coalesce(t2.id, ID) as Id,
    m.year,
    m.monthname,
    m.monthnum,
    t2.day,
    --group_concat(DISTINCT t2.isPregnant) as isPregnant,
    group_concat(DISTINCT t2.value, chr(10)) as value,

    FROM ldk.monthRange m
    LEFT JOIN study.reproSummaryRawData t2 ON (m.year = t2.year AND m.monthNum = t2.monthNum AND t2.Id = ID)
    GROUP BY m.year, m.monthname, m.monthnum, t2.day, t2.id
    PIVOT value BY day IN (SELECT value FROM ldk.integers i WHERE i.value > 0 AND i.value <=31 ORDER BY i.value))pvt

LEFT OUTER JOIN

(SELECT
    coalesce(t2.id, ID) as Id,
    m.year,
    m.monthname,
    m.monthnum,
    group_concat(DISTINCT t2.isPregnant) as isPregnant

    FROM ldk.monthRange m
    LEFT JOIN study.reproSummaryRawData t2 ON (m.year = t2.year AND m.monthNum = t2.monthNum AND t2.Id = ID)
    GROUP BY m.year, m.monthname, m.monthnum, t2.id) grp

ON pvt.id = grp.id AND pvt.monthnum = grp.monthnum AND pvt.year = grp.year