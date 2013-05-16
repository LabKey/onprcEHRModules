/*
 * Copyright (c) 2013 LabKey Corporation
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
  d1.id,
  d1.date as birth,

  h.id as potentialParent,
  h.id.demographics.gender as parentGender,
  CASE
    WHEN h.id.demographics.gender = 'm' THEN 'Potential Sire'
    WHEN h.id.demographics.gender = 'f' THEN 'Potential Dam'
    ELSE 'Unknown'
  END as category,

FROM (

SELECT

  d.id,
  d.date,
  timestampadd('SQL_TSI_DAY', -190, d.date) as minDate,
  timestampadd('SQL_TSI_DAY', -155, d.date) as maxDate,
  d.room,

FROM study.birth d

) d1

LEFT JOIN study.housing h ON (h.date <= d1.maxDate AND h.enddateCoalesced >= d1.minDate AND d1.room = h.room)

--UNION ALL

-- TODO: account for animal groups

