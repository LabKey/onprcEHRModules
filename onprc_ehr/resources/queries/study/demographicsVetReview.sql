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
--  Created 4-24-2025  R. Blasa Recreated to allow additional filters

SELECT
    d.Id,
    group_concat(distinct d.Id.curLocation.room, chr(10)) as Room,
    group_concat(distinct d.Id.curLocation.cage, chr(10)) as Cage,
    group_concat(distinct d.mostRecentHX, chr(10)) as Hx,
    group_concat(distinct d.remarksEnteredSinceReview, chr(10)) as Remarks,
    group_concat(distinct d.mostRecentClinicalObservations.observations, chr(10)) as "Recent Observations",
    group_concat(distinct d.mostRecentClinicalObservations.date, chr(10)) as "Recent Observation Date",
    null as VomitObservations,
    null as vomitObservationsdate,
    group_concat(distinct cast(d.lastVetReview as date), chr(10)) as "Last Vet Review",
    group_concat(distinct d.Id.assignedVet.assignedVet, chr(10)) as "Assigned Vet",
    group_concat(distinct d.Id.utilization.use, chr(10)) as "Project",
    group_concat(distinct d.Id.activeCases.categories, chr(10)) as "Active Cases",
    group_Concat(distinct d.calculated_status, chr(10)) as "Status"

from  study.demographics d  where d.Id.assignedVet.assignedVet = 'dozier'
                              And d.totalRemarksEnteredSinceReview > 0

group by d.Id

Union

select
    e.Id,
    group_concat(distinct e.Id.curLocation.room, chr(10)) as Room,
    group_concat(distinct e.Id.curLocation.cage, chr(10)) as Cage,
    null as Hx,
    null as Remarks,
    null as  "Recent Observations",
    null as  "Recent Observation Date",
    group_concat(distinct g.Observations, chr(10)) as VomitObservations,
    group_concat(distinct g.date, chr(10)) as VomitObservationsdate,
    group_concat(distinct cast(e.lastVetReview as date), chr(10)) as "Last Vet Review",
    group_concat(distinct e.Id.assignedVet.assignedVet, chr(10)) as "Assigned Vet",
    group_concat(distinct e.Id.utilization.use, chr(10)) as "Project",
    group_concat(distinct e.Id.activeCases.categories, chr(10)) as "Active Cases",
    group_Concat(distinct e.calculated_status, chr(10)) as "Status"

from study.demographics e, study.mostRecentClinicalObservations_Vomit_ForAnimal g
where e.Id = g.Id

group by e.Id