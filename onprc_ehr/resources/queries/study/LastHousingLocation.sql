
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

--  Created: 12-19-2018  R.Blasa

select a.Id,(a.room + ' ' + coalesce(a.cage, '')) as location from study.housing a
where a.date in (Select max( b.date) from study.housing b
 where a.Id = b.Id
 and a.qcstate.publicdata = true )
