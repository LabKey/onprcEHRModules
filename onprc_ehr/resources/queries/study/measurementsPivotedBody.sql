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


select
  m.id,
  m.date,
  m.tissue,
  max(m.measurement) as value,
  m.remark

FROM study.measurementsPivotedRawData m
WHERE m.categories like '%Body%' and m.measurementNo = '1'

group by m.id, m.date, m.tissue, m.parentid, m.remark

pivot value by tissue