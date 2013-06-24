/*
 * Copyright (c) 2012-2013 LabKey Corporation
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
f.id,
COALESCE(f.category, 'Other') as flags,
group_concat(f.value, chr(10)) as valueField

FROM study.flags f

WHERE f.isActive = true and f.category is not null

GROUP BY f.id, COALESCE(f.category, 'Other')

PIVOT valueField by flags

