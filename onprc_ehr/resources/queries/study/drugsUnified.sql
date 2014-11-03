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
  'Order' as type,
  t.Id,
  t.date,
  t.enddate,
  t.project,
  null as chargetype,
  t.category,
  t.code,
  t.frequency,
  t.route,
  t.concentration,
  t.conc_units,
  t.dosage,
  t.dosage_units,
  t.volume,
  t.vol_units,
  t.amount,
  t.amount_units,
  t.performedby,
  t.remark,
  t.taskid,
  t.requestid,
  t.container,
  t.lsid,
  t.objectid,
  t.qcstate,
  t.created,
  t.createdby,
  t.modified,
  t.modifiedby

FROM study.treatment_order t

UNION ALL

SELECT
  'One Time' as type,
  d.Id,
  d.date,
  null as enddate,
  d.project,
  d.chargetype,
  d.category,
  d.code,
  null as frequency,
  d.route,
  d.concentration,
  d.conc_units,
  d.dosage,
  d.dosage_units,
  d.volume,
  d.vol_units,
  d.amount,
  d.amount_units,
  d.performedby,
  d.remark,
  d.taskid,
  d.requestid,
  d.container,
  d.lsid,
  d.objectid,
  d.qcstate,
  d.created,
  d.createdby,
  d.modified,
  d.modifiedby

FROM study.drug d
WHERE d.treatmentid IS NULL