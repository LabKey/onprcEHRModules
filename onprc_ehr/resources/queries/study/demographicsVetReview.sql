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
 d.*,
 d.mostRecentClinicalObservations.date as observationdate,
 d.mostRecentClinicalObservations.observations,
 es.observations as vomitobservation,
 es.date as vomitdate

FROM  Site.{ substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.demographics d,
study.mostRecentClinicalObservations_Vomit_ForAnimal es
Where (d.id = es.id) And (d.totalRemarksEnteredSinceReview >  0
   or  es.category is not null )
