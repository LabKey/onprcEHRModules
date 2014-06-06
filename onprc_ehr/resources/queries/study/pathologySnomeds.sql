/*
 * Copyright (c) 2014 LabKey Corporation
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
  h.Id,
  h.date,
  h.formSort,
  'Histology' as type,
  h.tissue,
  h.codes,
  h.lsid,
  h.objectid,
  h.parentid,
  h.parentid.caseno as caseno

FROM study.histology h
WHERE h.qcstate.publicdata = true and h.codes IS NOT NULL

UNION ALL

SELECT
  h.Id,
  h.date,
  h.formSort,
  'Diagnosis' as type,
  null as tissue,
  h.codes,
  h.lsid,
  h.objectid,
  h.parentid,
  h.parentid.caseno as caseno

FROM study.pathologyDiagnoses h
WHERE h.qcstate.publicdata = true