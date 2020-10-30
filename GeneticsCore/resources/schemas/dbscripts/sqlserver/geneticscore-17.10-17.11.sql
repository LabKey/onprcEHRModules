/*
 * Copyright (c) 2011 LabKey Corporation
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

CREATE TABLE geneticscore.taqman_probes (
  rowid int identity(1,1),
  probe varchar(100),
  target varchar(1000),

  container ENTITYID,
  created DATETIME,
  createdby USERID,
  modified DATETIME,
  modifiedby USERID,

  CONSTRAINT PK_taqman_probes PRIMARY KEY (rowid)
);

CREATE TABLE geneticscore.test_significance (
  rowid int identity(1,1),
  probe varchar(100),
  genotype varchar(100),
  label varchar(1000),
  comment varchar(4000),

  container ENTITYID,
  created DATETIME,
  createdby USERID,
  modified DATETIME,
  modifiedby USERID,

  CONSTRAINT PK_test_significance PRIMARY KEY (rowid)
);