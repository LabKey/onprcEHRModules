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
  p.Id,
  p.date,
  p.parent,
  p.relationship,
  p.method

FROM study.parentage p
WHERE p.qcstate.publicdata = true and p.enddateCoalesced <= now()

UNION ALL

SELECT
  b.Id,
  b.date,
  b.dam,
  'Dam' as relationship,
  'Observed' as method

FROM study.birth b
WHERE b.dam is not null and b.qcstate.publicdata = true

UNION ALL

SELECT
    b.Id,
    b.date,
    b.sire,
    'Sire' as relationship,
    'Observed' as method

FROM study.birth b
WHERE b.sire is not null and b.qcstate.publicdata = true