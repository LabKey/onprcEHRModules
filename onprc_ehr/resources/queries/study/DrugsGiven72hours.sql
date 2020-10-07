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

--  Created: 10-4-2019  R.Blasa

SELECT
  p.id as Id,
  p.date,
  timestampadd('SQL_TSI_HOUR',72,p.date ) as enddate,
  p.code.code as code,
  p.code.meaning as meaning,
  p.amountAndVolume,
  p.route,
  timestampdiff('SQL_TSI_HOUR',p.date, now() ) as ElapseHours,
    p.remark,
    p.category

FROM study.drug p
WHERE p.qcstate.publicdata = true
and timestampdiff('SQL_TSI_HOUR',p.date, now() ) < 73
and p.code = 'E-Y9723'
and p.route <> 'Spillage'

UNION

SELECT
  s.id as Id,
  s.date,
    timestampadd('SQL_TSI_HOUR',72,s.date ) as enddate,
  s.code.code as code,
  s.code.meaning as meaning,
  s.amountAndVolume,
  s.route,
  timestampdiff('SQL_TSI_HOUR',s.date, now() ) as ElapseHours,
    s.remark,
    s.category

FROM study.treatment_order s
WHERE s.qcstate.publicdata = true
and timestampdiff('SQL_TSI_HOUR',s.date, now() ) < 73
and s.code = 'E-Y9723'
and s.route <> 'Spillage'
