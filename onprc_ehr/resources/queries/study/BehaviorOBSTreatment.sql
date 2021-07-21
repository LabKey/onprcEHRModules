/*
 * Copyright (c) 2017 LabKey Corporation
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
--  Created: 12-16-2020  R.Blasa  Behavior OBS Treatment reports
SELECT
    t.Id,
    t.date,
    t.enddate ,
    t.project,
    t.code,
    t.code.code as SnomedCode,
    t.amountAndVolume,
    t.route,
    t.remark as drugremark,
    t.performedby as drugperformedby,
    t.QCState as drugQCState,
    t.taskid as drugtaskid,
    t.category as drugcategory,

    o.category,
    o.area,
    o.observation,
    o.remark,
    o.taskid,
    o.performedby,
    o.QCState



FROM study.drug t

         INNER JOIN study.clinical_observations o on
    ((t.Id = o.Id and t.date = o.date) and ( o.category.category = 'Behavior') and ( t.category = 'Behavior') and (t.enddate is null or t.enddate >= now()) )
