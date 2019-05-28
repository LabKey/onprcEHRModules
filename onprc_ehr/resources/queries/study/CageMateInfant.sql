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


select

a.id,
a.room,
e.offspringUnder1Yr as InfantCageMate,
a.QCState

 from study.housingRoommates a, study.demographicsInfantUnderOne e
where  a.RoommateId.Id = e.offspringUnder1Yr
And a.Id.DataSet.demographics.calculated_status.code = 'Alive'
And e.Id.DataSet.demographics.calculated_status.code = 'Alive'
and a.roommateEnd  is null
and a.qcstate = 18
and a.room.housingtype.value = 'Cage Location'