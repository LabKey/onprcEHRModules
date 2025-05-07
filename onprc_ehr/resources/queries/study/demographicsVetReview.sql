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
    group_concat(distinct d.Id.curLocation.room, chr(10)),
    group_concat(distinct d.Id.curLocation.cage, chr(10)),
    d.mostRecentHX,
    d.remarksEnteredSinceReview,
    group_concat(distinct d.mostRecentClinicalObservations.observations, chr(10)),
    group_concat(distinct d.mostRecentClinicalObservations.date, chr(10)),
    t.vomitobservation,
    t.vomitdate,
    d.lastVetReview,
    d.Id.utilization.use,
    d.Id.activeCases.categories,
    d.calculated_status

FROM study.demographics d
         LEFT JOIN (
    SELECT
    f.Id,
    group_concat(f.observations, chr(10)) as vomitobservation,
    group_concat(distinct f.date, chr(10)) as vomitdate

    FROM study.mostRecentClinicalObservations_Vomit_ForAnimal f
    Where  f.category is not null

    GROUP BY f.id
) t ON (d.id = t.id)
where d.remarksEnteredSinceReview > 0
group by d.Id
