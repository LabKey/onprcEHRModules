/*
 * Copyright (c) 2014 LabKey Corporation
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
CREATE TABLE onprc_ehr.vet_assignment (
  rowid int identity(1,1),
  userid int,
  area varchar(100),
  protocol varchar(100),

  container ENTITYID NOT NULL,
  created datetime,
  createdby int,
  modified datetime,
  modifiedby int,

  CONSTRAINT PK_vet_assignment PRIMARY KEY (rowid)
);