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

  m.id,
  m.date,
  m.gestation_days as gestation_days,
TIMESTAMPADD('SQL_TSI_DAY',(p.Gestation - m.gestation_days), curdate())   as ExpectedDelivery,
m.QCState

FROM study.pregnancyConfirmation m
INNER JOIN ehr_lookups.species p on (m.Id.DataSet.demographics.species = p.common )
And m.date in (select max(s.date) from study.pregnancyConfirmation s where s.id = m.id)
And m.Id.DataSet.demographics.calculated_status.code = 'Alive'
And p.Gestation is not null
And m.outcome.birthDate is null
And m.gestation_days is not null