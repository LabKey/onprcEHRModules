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
  d.Id,
  st.code.meaning as agent,
  max(st.interval) as testInterval,
  max(s.date) as lastTestDate,
  min(age_in_months(s.date, now())) as monthsSinceTest,
  CASE
    WHEN max(s.date) IS NULL THEN 0
    ELSE (max(st.interval) - min(age_in_months(s.date, now())))
  END as monthsUntilDue,
FROM study.demographics d
JOIN onprc_ehr.serology_test_schedule st ON (
  (st.species IS NULL OR d.species = st.species)
  AND (st.flag IS NULL OR (d.Id.spfStatus.status IS NOT NULL AND d.Id.spfStatus.status LIKE ('%' || st.flag || '%')))
)
LEFT JOIN study.serology s ON (d.Id = s.id AND s.agent = st.code)

GROUP BY d.Id, st.code.meaning

--PIVOT lastTestDate, monthsSinceTest, monthsUntilDue by agent