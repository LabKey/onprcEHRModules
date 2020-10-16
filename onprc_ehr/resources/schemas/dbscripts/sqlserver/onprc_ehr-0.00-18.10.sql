/*
 * Copyright (c) 2012 LabKey Corporation
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
/* onprc_ehr-12.20-12.30.sql */

/* onprc_ehr-12.20-12.21.sql */

CREATE SCHEMA onprc_ehr;
GO
CREATE TABLE onprc_ehr.etl_runs
(
    RowId int identity(1,1),
    date datetime,

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);

/* onprc_ehr-12.21-12.22.sql */

ALTER TABLE onprc_ehr.etl_runs ADD queryname varchar(200);
ALTER TABLE onprc_ehr.etl_runs ADD rowversion varchar(200);

CREATE TABLE onprc_ehr.investigators (
    rowId int identity(1,1) NOT NULL,
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),
    investigatorType varchar(100),
    emailAddress varchar(100),
    dateCreated datetime,
    dateDisabled datetime,
    division varchar(100),
    financialAnalyst int,

    createdby userid,
    created datetime,
    modifiedby userid,
    modified datetime,
    CONSTRAINT pk_investigators PRIMARY KEY (rowid)
);

ALTER TABLE onprc_ehr.investigators ADD objectid ENTITYID;

alter table onprc_ehr.investigators add assignedVet int;

create table onprc_ehr.serology_test_schedule (
  rowid int identity(1,1),
  code varchar(100),
  flag varchar(100),
  interval int,

  CONSTRAINT PK_serology_test_schedule PRIMARY KEY (rowid)
);

INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32140','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY351','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3284','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY331','SPF', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32221','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32140','SPF 9', 3);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-32218','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY351','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY370','SPF 9', 1);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3283','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3284','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-Y3287','SPF 9', 12);
INSERT INTO onprc_ehr.serology_test_schedule (code, flag, interval) VALUES ('E-YY331','SPF 9', 12);

--implemented based on SQLServer database engine tuning monitor
CREATE INDEX investigators_rowid_lastname ON onprc_ehr.investigators (rowid, lastname);

CREATE TABLE onprc_ehr.tissue_recipients (
  rowId int identity(1,1) NOT NULL,
  firstName varchar(100),
  lastName varchar(100),
  institution varchar(100),

  title varchar(1000),
  affiliation varchar(1000),
  address varchar(1000),
  city varchar(100),
  state varchar(100),
  country varchar(100),
  zip varchar(100),
  phoneNumber varchar(100),
  recipientType varchar(100),
  emailAddress varchar(100),

  shipAddress varchar(1000),
  shipCity varchar(100),
  shipState varchar(100),
  shipCountry varchar(100),
  shipZip varchar(100),

  dateCreated DATETIME,
  dateDisabled DATETIME,

  investigatorId int,

  objectid entityid,
  container entityid,
  createdby userid,
  created DATETIME,
  modifiedby userid,
  modified DATETIME,
  CONSTRAINT pk_tissue_recipients PRIMARY KEY (rowid)
);

ALTER TABLE onprc_ehr.investigators ADD userid int;

ALTER TABLE onprc_ehr.investigators ADD employeeid varchar(100);

--added to facilitate the split billing code into a separate module from ONPRC_EHR.
--this should cause the server to think all existing scripts were in fact run, even though they ran as the onprc_ehr module
INSERT INTO core.SqlScripts (Created, Createdby, Modified, Modifiedby, FileName, ModuleName)
SELECT Created, Createdby, Modified, Modifiedby, FileName, 'ONPRC_Billing' as ModuleName
FROM core.SqlScripts
WHERE FileName LIKE 'onprc_billing-%'AND ModuleName = 'ONPRC_EHR';

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

ALTER TABLE onprc_ehr.vet_assignment add room varchar(100);

ALTER TABLE onprc_ehr.vet_assignment add priority integer;

EXEC sp_rename 'onprc_ehr.tissue_recipients', 'customers';

ALTER TABLE onprc_ehr.vet_assignment DROP COLUMN priority;
GO
ALTER TABLE onprc_ehr.vet_assignment add priority bit;

CREATE TABLE onprc_ehr.housing_transfer_requests (
  Id varchar(100),
  date datetime,
  room varchar(200),
  cage varchar(100),
  reason varchar(100),
  remark varchar(4000),
  qcstate int,

  requestid entityid,
  objectid entityid NOT NULL,
  container entityid,
  created datetime,
  createdby int,
  modified datetime,
  modifiedby int,

  CONSTRAINT PK_housing_transfer_requests PRIMARY KEY (objectid)
);

ALTER TABLE onprc_ehr.housing_transfer_requests ADD divider integer;
ALTER TABLE onprc_ehr.housing_transfer_requests ADD formSort integer;

UPDATE ehr.tasks SET formtype = 'Bulk Clinical Entry' WHERE formtype = 'Clinical Remarks';

CREATE TABLE onprc_ehr.birth_condition (
    rowid int identity(1,1),
    value varchar(200),
    alive bit,
    description varchar(4000),
    container entityid,
    createdby int,
    created datetime,
    modifiedby int,
    modified datetime,

    CONSTRAINT PK_birth_condition PRIMARY KEY (rowid)
);

--this should be OK since we declare a dependency on EHR, meaning its scripts will run first
UPDATE ehr.qcStateMetadata SET draftData = 1 WHERE QCStateLabel = 'Request: Pending';

CREATE TABLE onprc_ehr.observation_types (
    value varchar(200),
    category varchar(200),
    editorconfig varchar(4000),
    schemaname varchar(200),
    queryname varchar(200),
    valuecolumn varchar(200),
    createdby int,
    created datetime,
    modifiedby int,
    modified datetime,

    CONSTRAINT PK_observation_types PRIMARY KEY (value)
);

ALTER TABLE onprc_ehr.serology_test_schedule ADD species VARCHAR(100);

CREATE TABLE onprc_ehr.encounter_summaries_remarks (

  id varchar(100),
  date datetime,
  parentid entityid,
  schemaName varchar(100),
  queryName varchar(100),
  remark text,

  objectid varchar(60) NOT NULL,
  container entityid NOT NULL,
  createdby smallint,
  created datetime,
  modifiedby smallint,
  modified datetime,
  taskid  entityid,
  category varchar(100),
  formsort integer

  constraint pk_encounter_summaries_remarks PRIMARY KEY (objectid)
);

CREATE TABLE onprc_ehr.NHP_Training(
	 RowId INT IDENTITY(1,1)NOT NULL,
   Id                  varchar(100),
	 date                datetime  NULL,
   training_Ending_Date datetime NULL,
	 training_type        varchar(255) NULL,
	 reason              varchar(255) NULL,
	 qcstate              INTEGER    NULL,
   taskid 	             nvarchar(4000) NULL,
   remark              nvarchar(4000) NULL,
   objectid 	          ENTITYID NOT NULL,
   formSort             SMALLINT  NULL,
   performedby   	      nvarchar(4000) NULL,
	 createdby            int NULL,
	 created              datetime NULL,
	 modifiedby           int NULL,
	 modified             datetime  NULL,
	 Container 	          ENTITYID,
	 training_results     varchar(255) NULL

 CONSTRAINT PK_NHPTrainingObject PRIMARY KEY (objectid)
);

GO


---- BEGIN contents of onprc_ehr-17.20-17.21.sql (script in release20.7-SNAPSHOT), which is also in onprc_ehr-20.414-20.415.sql (script in onprc19.1Prod)
-- Upgrading from release20.7-SNAPSHOT (module v. 18.10), will already have below run as part of onprc_ehr-17.20-17.21.sql
-- Upgrading from onprc19.1Prod (module v. 20.417), will already have below run as part of onprc_ehr-20.414-20.415.sql

--Add container column
ALTER TABLE onprc_ehr.observation_types ADD container entityid;
GO

--Add container ids to onprc_ehr.observation_types:
UPDATE onprc_ehr.observation_types
SET container = (SELECT c.entityid FROM core.containers c
                                            LEFT JOIN core.Containers c2 ON c.Parent = c2.EntityId
                 WHERE c.name = 'EHR' and c2.name = 'ONPRC')
WHERE container IS NULL;
GO

--copy data into ehr table
INSERT INTO ehr.observation_types
(value,
 category,
 editorconfig,
 schemaName,
 queryName,
 valueColumn,
 createdby,
 created,
 modifiedby,
 modified,
 container
)
SELECT
    value,
    category,
    editorconfig,
    schemaName,
    queryName,
    valueColumn,
    createdby,
    created,
    modifiedby,
    modified,
    container
FROM onprc_ehr.observation_types obs
WHERE obs.container IS NOT NULL;
GO

--drop table
DROP TABLE onprc_ehr.observation_types
GO

---- END contents of onprc_ehr-17.20-17.21.sql...
