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

SELECT

    h1.Id,
    group_concat(h2.Id) as InfantCageMate

FROM study.demographicsCurrentLocation h1
JOIN study.demographicsCurrentLocation h2 ON (
    h1.room = h2.room AND
    h1.cage = h2.cage AND
    h1.Id != h2.Id
)

WHERE
        h1.room.housingType.value = 'Cage Location' AND
        h2.Id.age.ageInyears < 1

GROUP BY h1.Id
