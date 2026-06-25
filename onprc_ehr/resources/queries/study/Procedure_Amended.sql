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
    t.id,
    t.date,
    t.procedureid,
    t.qcstate,
    t.taskid,
    t.type,
    t.remark,
    t.requestid,
    t.chargetype,
    t.project,
    t.objectid,
    t.Id.curLocation.room,
    t.Id.curLocation.area


FROM study.encounters t
Where  t.type in ('Procedure')
UNION
SELECT
        j.id,
      j.date,
j.procedureid,
    j.qcstate,
     j.taskid,
       j.type,
     j.remark,
   j.requestid,
  j.chargetype,
      j.project,
      j.objectid,
      j.Id.curLocation.room,
        j.Id.curLocation.area


FROM study.encounters j
where j.procedureid.name in ('TB Test Intradermal')
  And j.type in ('Surgery')

