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
  t1.Id,
  e.date,
  e.caseno,
  t1.type,
  t1.sort_order,
  t1.codes,
  t1.codesMeaning,
  t1.meaning
FROM (
SELECT

e.Id,
e.recordid,
e.sort_order,
e.parentid,
group_concat(DISTINCT e.type) as type,
group_concat(e.codeWithSort, chr(10)) as codes,
group_concat(e.codeMeaning, chr(10)) as codesMeaning,
group_concat(e.meaning, chr(10)) as meaning

FROM (

SELECT
  pd.Id,
  pd.date,
  'Diagnosis' as type,
  --e.objectid,
  --e.caseno,
  s.recordid,
  pd.sort_order,
  pd.parentid,
  cast(s.codeWithSort as varchar) as codeWithSort,
  s.code,
  sno.meaning,
  cast((cast(s.sort as varchar(10)) || cast(': ' as varchar(2)) || sno.meaning || ' (' || s.code || ')') as varchar(2000)) as codeMeaning

FROM ehr.snomed_tags s
JOIN study.pathologyDiagnoses pd ON (s.recordid = pd.objectid)
JOIN ehr_lookups.snomed sno ON (s.code = sno.code)

UNION ALL

SELECT
  pd.Id,
  pd.date,
  'Histology' as type,
  --e.objectid,
  --e.caseno,
  s.recordid,
  pd.formSort as sort_order,
  pd.parentid,
  cast(s.codeWithSort as varchar) as codeWithSort,
  s.code,
  sno.meaning,
  cast((cast(s.sort as varchar(10)) || cast(': ' as varchar(2)) || sno.meaning || ' (' || s.code || ')') as varchar(2000)) as codeMeaning

FROM ehr.snomed_tags s
JOIN study.histology pd ON (s.recordid = pd.objectid)
JOIN ehr_lookups.snomed sno ON (s.code = sno.code)

) e

GROUP BY e.Id, e.recordid, e.parentid, e.sort_order

) t1

JOIN study.encounters e ON (e.Id = t1.Id AND e.objectid = t1.parentid)