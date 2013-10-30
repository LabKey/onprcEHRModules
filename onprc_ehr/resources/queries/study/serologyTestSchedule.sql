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
  f.id,
  st.code.meaning as agent,
  f.flag,
  max(st.interval) as testInterval,
  max(s.date) as lastTestDate,
  --min(timestampdiff('SQL_TSI_MONTH', s.date, now())) as monthsSinceTest,
  min(age_in_months(s.date, now())) as monthsSinceTest,
  CASE
    WHEN max(s.date) IS NULL THEN 0
    --ELSE (max(st.interval) - min(timestampdiff('SQL_TSI_MONTH', s.date, now())))
    ELSE (max(st.interval) - min(age_in_months(s.date, now())))
  END as monthsUntilDue,
FROM study.flags f
JOIN onprc_ehr.serology_test_schedule st ON (st.flag = f.value)
LEFT JOIN study.serology s ON (f.id = s.id AND s.agent = st.code)

WHERE f.isActive = true

GROUP BY f.id, f.flag, st.code.meaning

--PIVOT lastTestDate, monthsSinceTest, monthsUntilDue by agent