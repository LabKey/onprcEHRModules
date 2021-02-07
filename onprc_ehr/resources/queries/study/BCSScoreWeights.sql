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

    p.Id,
    p.date,
    k.weight,
    k.date as weightdate,
    rtrim(ltrim(p.observation)) as observation,
    TIMESTAMPDIFF('SQL_TSI_DAY', p.date, now()) as duration


FROM study.Clinical_Observations p, study.weight K
WHERE p.qcstate.publicdata = true
  And (p.id = k.id)
  And p.category = 'BCS'
  And p.date in (Select max(r.date) from study.Clinical_Observations r, study.Weight j
                 Where r.category = 'BCS' And r.id = p.id And r.id = j.id
                   And (TIMESTAMPDIFF('SQL_TSI_DAY', j.date, r.date) < 8) And r.qcstate = 18 And j.qcstate = 18)

  And (K.date in (select min(s.date) as date  from study.Weight s Where s.Id = k.Id And ( (TIMESTAMPDIFF('SQL_TSI_DAY', s.date, p.date) <= 0) And (TIMESTAMPDIFF('SQL_TSI_DAY', s.date, p.date) > -8) ) And s.qcstate = 18)
    or K.date in (select max(s.date) as date  from study.Weight s Where s.Id = k.Id And ( (TIMESTAMPDIFF('SQL_TSI_DAY', s.date, p.date) < 8) And (TIMESTAMPDIFF('SQL_TSI_DAY', s.date, p.date) > 0) ) And s.qcstate = 18)  )
