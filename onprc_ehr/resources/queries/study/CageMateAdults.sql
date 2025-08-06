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
    group_concat(h1.Id, '; ') as adultcagemate,

    group_Concat(distinct h1.room) as room,
    group_concat(distinct h1.Id.curLocation.cage) as cage


FROM study.demographicspaired h1


where

    h1.room.housingType.value = 'Cage Location'


group by h1.room, h1.Id.curLocation.cage, h1.Id


