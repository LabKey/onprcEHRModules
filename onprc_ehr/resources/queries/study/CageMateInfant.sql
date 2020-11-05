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
group_concat(e.Id ) as InfantCageMate,
a.QCState


 from study.housing a, study.demographics e
where  a.Id <> e.Id
And e.calculated_status.code = 'Alive'
and a.Enddate  is null
and a.qcstate = 18 and e.qcstate = 18
and a.housingType.value = 'Cage Location'
and (a.room.room = e.Id.curLocation.room and a.cage = e.Id.curLocation.cage)
and e.Id.age.ageInyears < 1


Group by a.id, a.QCState


