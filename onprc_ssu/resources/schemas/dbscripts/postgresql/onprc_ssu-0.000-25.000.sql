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

CREATE SCHEMA onprc_ssu;

CREATE TABLE onprc_ssu.schedule (
  rowid SERIAL,
  Id varchar(100),
  date timestamp,
  location varchar(200),
  procedureid int,

  objectid entityid not null,

  container entityid,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  constraint PK_schedule PRIMARY KEY (objectid)
);

ALTER TABLE onprc_ssu.schedule ADD project integer;

ALTER TABLE onprc_ssu.schedule ADD formcreated boolean;
ALTER TABLE onprc_ssu.schedule ADD encounterid entityid;
ALTER TABLE onprc_ssu.schedule ADD taskid entityid;
