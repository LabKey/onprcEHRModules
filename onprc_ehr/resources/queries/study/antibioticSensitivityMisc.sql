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
a.Id,
a.date,
a.runid.tissue as tissue,
a.microbe,
a.antibiotic,
a.result,
a.remark,
a.taskid,
a.requestid,
a.performedby

FROM study."Antibiotic Sensitivity" a
WHERE a.antibiotic NOT IN (
  'E-71875',
  'E-719Y1',
  'E-719Y3',
  'E-72040',
  'E-72045',
  'E-721X0',
  'E-72360',
  'E-72500',
  'E-72600',
  'E-72682',
  'E-72720',
  'E-Y7240'
)