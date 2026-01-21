/*
 * Copyright (c) 2013-2016 LabKey Corporation
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
  p.Id,
  p.date,
  p.parent,
  p.relationship,
  p.method,
  p.remark,
  'Parentage' as source

FROM study.parentage p
WHERE p.qcstate.publicdata = true and p.enddate is null
And  p.date in (select max(t.date) from study.parentage t where p.Id = t.Id And p.parent = t.parent
And p.relationship =t.relationship And p.method = t.method And t.enddate is null and p.enddate is null and t.qcstate.publicdata = true)

UNION

SELECT
  b.Id,
  b.date,
  b.dam,
  'Dam' as relationship,
  'Observed' as method,
  null as remark,
  'Birth' as source

FROM study.birth b
WHERE b.dam is not null and b.qcstate.publicdata = true

UNION

SELECT
    a.Id,
     a.date,
    a.sire,
    'Sire' as relationship,
    'Observed' as method,
     null as remark,
    'Birth' as source

FROM study.birth a
WHERE a.sire is not null and a.qcstate.publicdata = true
