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

/* 18.xxx SQL scripts */

-- includes content of onprc_ehr-12.395-12.396.sql to onprc_ehr-17.704-17.705.sql from onprc19.1Prod
-- removing all references to eIACUC processing



CREATE TABLE [onprc_ehr].[AvailableBloodVolume](
    [datecreated] [datetime] NULL,
    [id] [nvarchar](32) NULL,
    [gender] [nvarchar](4000) NULL,
    [species] [nvarchar](4000) NULL,
    [yoa] [float] NULL,
    [mostrecentweightdate] [datetime] NULL,
    [weight] [float] NULL,
    [calcmethod] [nvarchar](32) NULL,
    [BCS] [float] NULL,
    [BCSage] [int] NULL,
    [previousdraws] [float] NULL,
    [ABV] [float] NULL,
    [dsrowid] [bigint] NOT NULL
    ) ON [PRIMARY]
    GO

CREATE TABLE onprc_ehr.Reference_StaffNames(
                                               RowId                    INT IDENTITY(1,1)NOT NULL,
                                               username                 varchar(100),
                                               LastName                 varchar(100) NULL,
                                               FirstName                varchar(100) NULL,
                                               displayname               varchar(100) NULL,
                                               Type                     varchar(100) NULL,
                                               role                     varchar(100) NULL,
                                               remark                   varchar(200) NULL,
                                               SortOrder                smallint  NULL,
                                               StartDate                smalldatetime NULL,
                                               DisableDate              smalldatetime NULL

                                                   CONSTRAINT pk_reference PRIMARY KEY (username)

);

CREATE TABLE onprc_ehr.Frequency_DayofWeek(
                                              RowId                    INT IDENTITY(1,1)NOT NULL,
                                              FreqKey                  SMALLINT  NULL,
                                              value                    SMALLINT  NULL,
                                              Meaning                  varchar(400) NULL,
                                              calenderType             varchar(100) NULL,
                                              Sort_order               SMALLINT NULL,
                                              DisableDate              smalldatetime NULL

                                                  CONSTRAINT pk_FreqWeek PRIMARY KEY (RowId)

);

CREATE TABLE onprc_ehr.usersActiveNames(
    Email nvarchar(64) NULL,
    _ts timestamp NOT NULL,
    EntityId ENTITYID NULL,
    CreatedBy USERID NULL,
    Created datetime NULL,
    ModifiedBy USERID NULL,
    Modified datetime NULL,
    Owner USERID NULL,
    UserId USERID NOT NULL,
    DisplayName nvarchar(64) NOT NULL,
    FirstName nvarchar(64) NULL,
    LastName nvarchar(64) NULL,
    Phone nvarchar(64) NULL,
    Mobile nvarchar(64) NULL,
    Pager nvarchar(64) NULL,
    IM nvarchar(64) NULL,
    Description nvarchar(255) NULL,
    LastLogin datetime NULL,
    Active bit NOT NULL
    )
    GO

/* 20.xxx SQL scripts */

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.animalGroups Dataset which is populated by the ETL Process
 *
 */
CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Parent_Protocol] [varchar](255) NOT NULL,
	[Group_ID] [varchar](255) NULL,
	[Group_Name] [varchar](255) NULL,
	[Species] [varchar](255) NULL,
	[SPF_Status] [varchar](255) NULL,
	[Weight_Start] [varchar](255) NULL,
	[Weight_End] [varchar](255) NULL,
	[Age_Start] [varchar](255) NULL,
	[Age_End] [varchar](255) NULL,
	[Gender] [varchar](255) NULL,
	[Number_of_Animals_Max] [int] NULL,
	[Breeding_Colony] [int] NULL,
	[Non_Standard_Housing_Types] [nvarchar](max) NULL,
	[Non_Standard_Housing_Description] [nvarchar](max) NULL,
	[Non_Standard_Housing_Frequency_and_Duration][nvarchar](max) NULL,
	[Non_Standard_Housing_Monitoring] [nvarchar](max) NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL,
	[Restraint] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Description] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Adverse_Consequences] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Health_Assessment] [nvarchar](max) NULL,
	[Non_Pharmaceutical_Grade_Drug_Use] [nvarchar](max) NULL,
	[Food_Withheld] [int] NULL,
	[Water_Withheld] [int] NULL,
	[Food_Water_Withheld_Description] [nvarchar](max) NULL,
	[Food_Water_Withheld_Justification] [nvarchar](max) NULL,
	[Food_Water_Withheld_Adverse_Consequences] [nvarchar](max) NULL,
	[Death_As_Endpoint_Number_of_Animals] [nvarchar](max) NULL,
	[Death_As_Endpoint_Justification] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.IBC_Numberss Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_IBC_NUMBERS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Animal_Group] [varchar](255) NOT NULL,
	[IBC_Registration_Number] [varchar](255) NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL
) ON [PRIMARY]
GO

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.PRIME_VIEW_NON_SURGICAL_PROCS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_NON_SURGICAL_PROCS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Animal_Group] [varchar](255) NOT NULL,
	[NS_Procedure_Name] [varchar](255) NULL,
	[Standard_Procedure] [int] NULL,
	[Iterations] [int] NULL,
	[Deviation] [int] NULL,
	[Deviation_Description] [varchar](255) NULL,
	[Recovery_Days] [int] NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL
) ON [PRIMARY]
GO

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.PRIME_VIEW_PROTOCOLS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Protocol_ID] [varchar](255) NOT NULL,
	[Template_OID] [varchar](32) NULL,
	[Protocol_OID] [varchar](255) NULL,
	[Protocol_Title] [varchar](255) NULL,
	[PI_ID] [varchar](255) NULL,
	[PI_First_Name] [varchar](255) NULL,
	[PI_Last_Name] [varchar](255) NULL,
	[PI_Email] [varchar](255) NULL,
	[PI_Phone] [varchar](255) NULL,
	[USDA_Level] [varchar](255) NULL,
	[Approval_Date] [datetime] NULL,
	[Annual_Update_Due] [datetime] NULL,
	[Three_year_Expiration] [datetime] NULL,
	[Last_Modified] [datetime] NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL,
	[PROTOCOL_State] [varchar](250) NULL,
	[PPQ_Numbers] [varchar](255) NULL,
	[Description] [varchar](255) NULL
) ON [PRIMARY]
GO

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.PRIME_VIEW_SURGICAL_PROCS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_SURGICAL_PROCS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[OID] [int] NOT NULL,
	[Animal_Group] [varchar](255) NOT NULL,
	[Standard_Procedure] [int] NULL,
	[Iterations] [int] NULL,
	[Deviation] [int] NULL,
	[Deviation_Description] [varchar](255) NULL,
	[Recovery_Days] [int] NULL,
	[Surgery_Name] [varchar](255) NULL
) ON [PRIMARY]
GO

/* Licensed under the Apache License, Version 2.0 (the "License");
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
 * 2020/1/24 Update of Fields to accomodate incoming text straing.
 * Manual updated the Database schema to verify that it resolved the issue
 * This script creates the ONPRC_EHR.animalGroups Dataset which is populated by the ETL Process
 *
 */


/****** Object:  Table [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]    Script Date: 1/24/2020 12:23:44 PM ******/
DROP TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]
GO

/****** Object:  Table [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]    Script Date: 1/24/2020 12:23:44 PM ******/

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS](
	[rowid] [int] IDENTITY(1,1) NOT NULL,
	[Parent_Protocol] [varchar](255) NOT NULL,
	[Group_ID] [varchar](255) NULL,
	[Group_Name] [varchar](255) NULL,
	[Species] [varchar](255) NULL,
	[SPF_Status] [varchar](255) NULL,
	[Weight_Start] [varchar](255) NULL,
	[Weight_End] [varchar](255) NULL,
	[Age_Start] [varchar](255) NULL,
	[Age_End] [varchar](255) NULL,
	[Gender] [varchar](255) NULL,
	[Number_of_Animals_Max] [int] NULL,
	[Breeding_Colony] [int] NULL,
	[Non_Standard_Housing_Types] [nvarchar](max) NULL,
	[Non_Standard_Housing_Description] [ntext] NULL,
	[Non_Standard_Housing_Frequency_and_Duration] [nvarchar](max) NULL,
	[Non_Standard_Housing_Monitoring] [nvarchar](max) NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL,
	[Restraint] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Description] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Adverse_Consequences] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Health_Assessment] [nvarchar](max) NULL,
	[Non_Pharmaceutical_Grade_Drug_Use] [ntext] NULL,
	[Food_Withheld] [int] NULL,
	[Water_Withheld] [int] NULL,
	[Food_Water_Withheld_Description] [nvarchar](max) NULL,
	[Food_Water_Withheld_Justification] [nvarchar](max) NULL,
	[Food_Water_Withheld_Adverse_Consequences] [nvarchar](max) NULL,
	[Death_As_Endpoint_Number_of_Animals] [nvarchar](max) NULL,
	[Death_As_Endpoint_Justification] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [onprc_ehr].[PotentialSire_source]    Script Date: 4/121/20202 7:00:04 AM ******/
/****** Object:  Table [onprc_ehr].[PotentialDam_source]    Script Date: 4/121/20202 7:00:04 AM ******/
/****** Object:  Table [onprc_ehr].[PotentialParents_source]    Script Date: 4/121/20202 7:00:04 AM ******/

EXEC core.fn_dropifexists 'potentialDam_Source','onprc_ehr','TABLE';
GO

EXEC core.fn_dropifexists 'potentialsire_Source','onprc_ehr','TABLE';
GO

EXEC core.fn_dropifexists 'potentialParents_Source','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[PotentialSire_source]    Script Date: 4/121/20202 7:00:04 AM ******/
CREATE TABLE [onprc_ehr].[PotentialSire_source](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
	[participantId] [nvarchar](32) NULL,
	[Date] [datetime] NULL,
    [Species] [nvarchar](100) NULL,
    [room][nvarchar](100) NULL,
    [cage][nvarchar](100) NULL,
    [SireAgeAtTime] [datetime] NULL,
    [PotentialSire] [nvarchar](100) NULL,
    [SireBirth] [datetime] NULL,
    [Siregender] [nvarchar](100) NULL,
    [Sirespecies] [nvarchar](100) NULL,
    [SireDeath] [datetime] NULL,
	[created] [datetime] NULL,
	[createdBy] [int] NULL,
	[modified] [datetime] NULL,
	[modifiedBy] [int] NULL,
	[container] ENTITYID

	CONSTRAINT pk_potentialSire PRIMARY KEY (rowID)
)


/****** Object:  Table [onprc_ehr].[PotentialSire_source]    Script Date: 4/121/20202 7:00:04 AM ******/
CREATE TABLE [onprc_ehr].[PotentialDam_source](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [participantId] [nvarchar](32) NULL,
    [Date] [datetime] NULL,
    [Species] [nvarchar](100) NULL,
    [room][nvarchar](100) NULL,
    [cage][nvarchar](100) NULL,
    [DamAgeAtTime] [datetime] NULL,
    [PotentialDam] [nvarchar](100) NULL,
    [DamBirth] [datetime] NULL,
    [Damgender] [nvarchar](100) NULL,
    [DamSpecies] [nvarchar](100) NULL,
    [DamDeath] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL,
    [container] ENTITYID

    CONSTRAINT pk_potentialDam PRIMARY KEY (rowID)
)



/****** Object:  Table [onprc_ehr].[PotentialParents_source]    Script Date: 4/121/20202 7:00:04 AM ******/
CREATE TABLE [onprc_ehr].[PotentialParents_source](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [participantId] [nvarchar](32) NULL,
    [BirthDate] [datetime] NULL,
    [Species] [nvarchar](100) NULL,
    [BirthRoom][nvarchar](100) NULL,
    [Birthcage][nvarchar](100) NULL,
    [ParentAgeAtTime] [datetime] NULL,
    [PotentialParent] [nvarchar](100) NULL,
    [[PotentialParentType] [nvarchar](100) NULL,
    [ParentBirth] [datetime] NULL,
    [Parentgender] [nvarchar](100) NULL,
    [ParentSpecies] [nvarchar](100) NULL,
    [ParentDeath] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL,
    [container] ENTITYID

    CONSTRAINT pk_potentialParent PRIMARY KEY (rowID)
)

GO

/****** Object:  StoredProcedure [onprc_ehr].[PotentialDam_Insert]    Script Date: 4/22/2020 10:16:00 AM ******/
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-04-22
-- Description:	SP runs a query to populate the Potential Sire Dataset
-- =============================================
    CREATE PROCEDURE [onprc_ehr].[PotentialDam_Insert]

    AS
    BEGIN
        --Potential Sire Query
--This will be used in generation of potential parents
        Truncate table [onprc_ehr].[PotentialDam_source]
        INSERT INTO [onprc_ehr].[PotentialDam_source]
        ([participantId]
        ,[Date]
        ,[Species]
        ,[room]
        ,[cage]
        ,[DamAgeAtTime]
        ,[PotentialDam]
        ,[DamBirth]
        ,[Damgender]
        ,[DamSpecies]
        ,[DamDeath]
        ,[created]
        ,[createdBy]
        ,[modified]
        ,[modifiedBy]
        ,[container]
        )
        select
            b.participantid,
            b.date,
            b.species,
            b.room,
            b.cage,
            DateDiff(day, d.birth, b.date) / 365 as SireAgeAtTime,
-- (timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, b.date) / 365) as damAgeAtTime
-- we want a list of potential dams that were of age at the time of the infants birth
-- So look at the housing table match the Room and Cage on that date
            h.participantID,
            d.birth as SireBirth,
            d.gender,
            d.species,
            d.death as SireDeath,
            GETDATE(),
            1011,
            GetDate(),
            1011,
            'CD17027B-C55F-102F-9907-5107380A54BE'
        from [studyDataset].[c6d202_birth] b
                 join [studyDataset].[c6d194_housing] h on
            (b.participantId != h.participantId AND
             (h.date <= b.date AND h.enddate >= b.date) AND
             h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
                --note: this is to always include observed parents
                OR h.participantid = b.dam
                )
                 join [studyDataset].[c6d203_demographics] d on d.participantid = h.participantid
                 join [studyDataset].[c6d203_demographics] d1 on d1.participantID = b.participantid
        WHERE d.gender = 'm' and DateDiff(day, d.birth, b.date) > 912.5 --(2.5 years)
          AND d.species = d1.species

    END

GO

/****** Object:  StoredProcedure [onprc_ehr].[PotentialSire_Insert]    Script Date: 4/22/2020 10:16:39 AM ******/
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-04-22
-- Description:	SP runs a query to populate the Potential Sire Dataset
-- =============================================


CREATE PROCEDURE [onprc_ehr].[PotentialSire_Insert]

    AS
    BEGIN
        --Potential Sire Query
--This will be used in generation of potential parents
        Truncate table [onprc_ehr].[PotentialSire_source]
        INSERT INTO [onprc_ehr].[PotentialSire_source]
        ([participantId]
        ,[Date]
        ,[Species]
        ,[room]
        ,[cage]
        ,[SireAgeAtTime]
        ,[PotentialSire]
        ,[sireBirth]
        ,[siregender]
        ,[sireSpecies]
        ,[SireDeath]
        ,[created]
        ,[createdBy]
        ,[modified]
        ,[modifiedBy]
        ,[container]
        )
        select
            b.participantid,
            b.date,
            b.species,
            b.room,
            b.cage,
            DateDiff(day, d.birth, b.date) / 365 as SireAgeAtTime,
            h.participantID,
            d.birth as SireBirth,
            d.gender,
            d.species,
            d.death as SireDeath,
            GETDATE(),
            1011,
            GetDate(),
            1011,
            'CD17027B-C55F-102F-9907-5107380A54BE'
        from [studyDataset].[c6d202_birth] b
                 join [studyDataset].[c6d194_housing] h on
            (b.participantId != h.participantId AND
             (h.date <= b.date AND h.enddate >= b.date) AND
             h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
                --note: this is to always include observed parents
                OR h.participantid = b.dam
                )
                 join [studyDataset].[c6d203_demographics] d on d.participantid = h.participantid
                 join [studyDataset].[c6d203_demographics] d1 on d1.participantID = b.participantid
        WHERE d.gender = 'm' and DateDiff(day, d.birth, b.date) > 912.5 --(2.5 years)
          AND d.species = d1.species

    END

GO

-- Dev machines on release20.7-SNAPSHOT would be on module v. 18.10, and will already have below run as part of onprc_ehr-17.20-17.21.sql, and won't be needing this script to run
-- Onprc devs/server will be getting upgraded from svn onprc19.1Prod, which is already on module v. 20.417, so won't be needing this script to run
-- Below is now part of rolled up script onprc_ehr-0.00-18.10.sql for bootstrapped database
-- Commenting it out instead of deleting this file in order to preserve script numbering continuity

--Add container column
-- ALTER TABLE onprc_ehr.observation_types ADD container entityid;
-- GO
--
-- --Add container ids to onprc_ehr.observation_types:
-- UPDATE onprc_ehr.observation_types
-- SET container = (SELECT c.entityid FROM core.containers c
--                  LEFT JOIN core.Containers c2 ON c.Parent = c2.EntityId
--                  WHERE c.name = 'EHR' and c2.name = 'ONPRC')
-- WHERE container IS NULL;
-- GO
--
-- --copy data into ehr table
-- INSERT INTO ehr.observation_types
-- (value,
-- category,
-- editorconfig,
-- schemaName,
-- queryName,
-- valueColumn,
-- createdby,
-- created,
-- modifiedby,
-- modified,
-- container
-- )
-- SELECT
--   value,
--   category,
--   editorconfig,
--   schemaName,
--   queryName,
--   valueColumn,
--   createdby,
--   created,
--   modifiedby,
--   modified,
--   container
-- FROM onprc_ehr.observation_types obs
-- WHERE obs.container IS NOT NULL;
-- GO
--
-- --drop table
-- DROP TABLE onprc_ehr.observation_types
-- GO

/****** Object:  StoredProcedure [onprc_ehr].[PotentialDam_Insert]    Script Date: 4/22/2020 10:16:00 AM ******/
-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-04-22
-- Modified 2020-08024
-- reset the gender to f was incorrectly set to M returning Male
-- Description:	SP runs a query to populate the Potential Sire Dataset
-- Peer Review
-- =============================================
    ALTER PROCEDURE [onprc_ehr].[PotentialDam_Insert]

    AS
    BEGIN
        --Potential Sire Query
--This will be used in generation of potential parents
        Truncate table [onprc_ehr].[PotentialDam_source]
        INSERT INTO [onprc_ehr].[PotentialDam_source]
        ([participantId]
        ,[Date]
        ,[Species]
        ,[room]
        ,[cage]
        ,[DamAgeAtTime]
        ,[PotentialDam]
        ,[DamBirth]
        ,[Damgender]
        ,[DamSpecies]
        ,[DamDeath]
        ,[created]
        ,[createdBy]
        ,[modified]
        ,[modifiedBy]
        ,[container]
        )
        select
            b.participantid,
            b.date,
            b.species,
            b.room,
            b.cage,
            DateDiff(day, d.birth, b.date) / 365 as SireAgeAtTime,
-- (timestampdiff('SQL_TSI_DAY', h.Id.demographics.birth, b.date) / 365) as damAgeAtTime
-- we want a list of potential dams that were of age at the time of the infants birth
-- So look at the housing table match the Room and Cage on that date
            h.participantID,
            d.birth as SireBirth,
            d.gender,
            d.species,
            d.death as SireDeath,
            GETDATE(),
            1011,
            GetDate(),
            1011,
            'CD17027B-C55F-102F-9907-5107380A54BE'
        from [studyDataset].[c6d202_birth] b
                 join [studyDataset].[c6d194_housing] h on
            (b.participantId != h.participantId AND
             (h.date <= b.date AND h.enddate >= b.date) AND
             h.room = b.room AND (h.cage = b.cage OR (h.cage is null and b.cage is null))
                --note: this is to always include observed parents
                OR h.participantid = b.dam
                )
                 join [studyDataset].[c6d203_demographics] d on d.participantid = h.participantid
                 join [studyDataset].[c6d203_demographics] d1 on d1.participantID = b.participantid
        WHERE d.gender = 'f' and DateDiff(day, d.birth, b.date) > 912.5 --(2.5 years)
          AND d.species = d1.species

    END

GO

EXEC core.fn_dropifexists 'StudyDetails_Reference_Data','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[StudyDetails_Reference_Data]    Script Date: 2/20/2020 ******/

CREATE TABLE [onprc_ehr].[StudyDetails_Reference_Data](
    [rowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NULL,
    [name] [nvarchar](1000) NULL,
    [remark] [nvarchar](4000) NULL,
    [sort_order] INT NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_StudyDetails_Reference_Data PRIMARY KEY (rowId)
    )
GO

ALTER TABLE onprc_ehr.vet_assignment ADD  project INT;

/****** Housing transfers alert project: By Kolli******/
/*
 Created 3 temp tables to get the list of NHP rooms usage.
 The stored proc manages the addition and deleting data from the temp tables
 at the time of execution via ETL process.
 */
EXEC core.fn_dropifexists 'availableCages_temp','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'availableCagesByRoom_temp','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'roomUtilization_temp','onprc_ehr','TABLE';

GO

-- Create the temp tables
CREATE TABLE [onprc_ehr].[availableCages_temp](
    [location] [varchar](50) NOT NULL,
    [room] [varchar](200) NULL,
    [cage] [varchar](200) NULL,
    [row] [varchar](200) NULL,
    [columnidx] [int] NULL,
    [cage_type] [varchar](200) NULL,
    [lowerCage] [varchar](200) NULL,
    [lower_cage_type] [varchar](200) NULL,
    [divider] [int] NULL,
    [isAvailable] [int] NULL,
    [isMarkedUnavailable] [int] NULL,
    )
;

CREATE TABLE [onprc_ehr].[availableCagesByRoom_temp](
    [room] [varchar](200) NULL,
    [availableCages] [int] NULL,
    [markedUnavailable] [int] NULL
    )
;

CREATE TABLE [onprc_ehr].[roomUtilization_temp](
    [room] [nvarchar](200) NULL,
    [availableCages] [int] NULL,
    [cagesUsed] [int] NULL,
    [markedUnavailable] [int] NULL,
    [cagesEmpty] [int] NULL,
    [totalAnimals] [int] NULL
    )
;

GO


-- Create the stored proc here
/****** Object:  StoredProcedure [onprc_ehr].[NHPRoomsUsage]   ******/

-- =============================================
-- Author:		Lakshmi Kolli
-- Create date: 3/6/2021
-- Description:	Get the list of NHP rooms usage. The procedure is scheduled using a ETL process
-- to list out the room utilization list at 4pm every day. The list is later used to check against for the
-- empty rooms with the current list of rooms usage.
-- =============================================
CREATE PROCEDURE [onprc_ehr].[NHPRoomsUsage]

AS
BEGIN

----Truncate the temp table first
delete from onprc_ehr.availableCages_temp

----Get the cages list and insert into the temp table
Insert Into onprc_ehr.availableCages_temp(location,room, cage, row, columnidx, cage_type, lowerCage, lower_cage_type, divider, isAvailable, isMarkedUnavailable)
SELECT
    CASE
        WHEN c.cage IS NULL THEN c.room
        ELSE (c.room + '-' + c.cage)
        END as location,
    c.room,
    c.cage,
    (Select cp.row from ehr_lookups.cage_positions cp where c.cage = cp.cage) as row,
    (Select cp.columnIdx from ehr_lookups.cage_positions cp where c.cage = cp.cage) as columnidx,
    c.cage_type,
    lc.cage as lowerCage,
    lc.cage_type as lower_cage_type,
    lc.divider,
    --if the divider on the left-hand cage is separating, then these cages are separate
    --and should be counted.  if there's no left-hand cage, always include
    CASE
        WHEN c.cage_type = 'No Cage' THEN 0
        --WHEN lc.divider.countAsSeparate = 0 THEN false
        WHEN (Select d.countAsSeparate from ehr_lookups.divider_types d where lc.divider = d.rowid) = 0 THEN 0
        ELSE 1
        END as isAvailable,

    CASE
        WHEN (c.status IS NOT NULL AND c.status = 'Unavailable') then 1
        ELSE 0
        END as isMarkedUnavailable

FROM ehr_lookups.cage c
         --find the cage located to the left
         LEFT JOIN ehr_lookups.cage lc ON (lc.cage_type != 'No Cage' and c.room = lc.room and (Select cp.row from ehr_lookups.cage_positions cp where c.cage = cp.cage) = (Select cp.row from ehr_lookups.cage_positions cp where lc.cage = cp.cage) and ((Select cp.columnIdx from ehr_lookups.cage_positions cp where c.cage = cp.cage) - 1) = (Select cp.columnIdx from ehr_lookups.cage_positions cp where lc.cage = cp.cage) )
--WHERE c.room.housingType.value = 'Cage Location'

----Truncate the temp table first
delete from onprc_ehr.availableCagesByRoom_temp

--Get the available cages by room
Insert Into onprc_ehr.availableCagesByRoom_temp(room, availableCages, markedUnavailable)
SELECT
    c.room,
    count(*) as availableCages,
    sum(c.isMarkedUnavailable) as markedUnavailable
FROM onprc_ehr.availableCages_temp c
WHERE c.isAvailable = 1
GROUP BY c.room

----Truncate the temp table first
delete from onprc_ehr.roomUtilization_temp

--Get the rooms usage data
Insert Into onprc_ehr.roomUtilization_temp(room, availableCages, CagesUsed, MarkedUnavailable, CagesEmpty, TotalAnimals)
SELECT
    r.room,
    max(cbr.availableCages) as AvailableCages,
    count(DISTINCT h.cage) as CagesUsed,
    max(cbr.markedUnavailable) as MarkedUnavailable,
    max(cbr.availableCages) - count(DISTINCT h.cage) - max(cbr.markedUnavailable) as CagesEmpty,
    count(DISTINCT h.participantid) as TotalAnimals
FROM ehr_lookups.rooms r
         LEFT JOIN (
            SELECT c.room, c.cage
            FROM ehr_lookups.cage c
            WHERE cage is not null

            --allow for rooms w/o cages
            UNION ALL
            SELECT r.room, null as cage
            FROM ehr_lookups.rooms r
        ) c on (r.room = c.room)
         LEFT JOIN studyDataset.c6d194_housing h ON (r.room=h.room AND (c.cage=h.cage OR (c.cage is null and h.cage is null)) AND (((date <= GETDATE() AND enddate >= GETDATE()) OR (date <= GETDATE() AND enddate is null))))
         LEFT JOIN onprc_ehr.availableCagesByRoom_temp cbr ON (cbr.room = r.room)
WHERE r.datedisabled is null
GROUP BY r.room

END

GO

EXEC core.fn_dropifexists 'PMIC_Reference_Data','onprc_ehr','TABLE';
    GO

/****** Object:  Table [onprc_ehr].[PMIC_Reference_Data]    Script Date: 2/12/2020 ******/
CREATE TABLE [onprc_ehr].[PMIC_Reference_Data](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NULL,
    [name] [nvarchar](1000) NULL,
    [remark] [nvarchar](4000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_PMIC_Reference_Data PRIMARY KEY (RowId)
    )

    GO

ALTER TABLE onprc_ehr.AvailableBloodVolume ALTER COLUMN Id nvarchar(32) NOT NULL;
GO

ALTER TABLE onprc_ehr.AvailableBloodVolume ADD CONSTRAINT PK_AvailableBloodVolume PRIMARY KEY (Id);
GO

/* 21.xxx SQL scripts */

EXEC core.fn_dropifexists 'ASB_SpecialInstructions','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[ASB_SpecialInstructions]   Script Date: 6/8/21 ******/
CREATE TABLE [onprc_ehr].[ASB_SpecialInstructions](
    [RowId]  INT IDENTITY(1,1)NOT NULL,
    [value] [nvarchar](1000) NOT NULL,
    [remarks] [nvarchar](2000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_ASB_SpecialInstructions PRIMARY KEY (RowId)
    )

    GO

EXEC core.fn_dropifexists 'ASB_SpecialInstructions','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[ASB_SpecialInstructions]   Script Date: 6/14/21 ******/
CREATE TABLE [onprc_ehr].[ASB_SpecialInstructions](
    [value] [nvarchar](1000) NOT NULL,
    [remarks] [nvarchar](2000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_ASB_SpecialInstructions PRIMARY KEY (value)
    )

    GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-17
-- Description:	Db tables creation for Prima reporting process. Created all the Prima tables in Prime onprc_ehr schema folder.
-- =======================================================================================================================================

--Drop if exists (Labkey syntax)
--Tables
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';
--Stored procs
EXEC core.fn_dropifexists 'PrimaSlideBillingReport', 'onprc_ehr', 'PROCEDURE';
EXEC core.fn_dropifexists 'PrimaBlockBillingReport', 'onprc_ehr', 'PROCEDURE';

GO

--Create tables
--1. UserPersons table
/****** Object:  Table [onprc_ehr].[Prima_UserPersons]  Script Date: 6/17/2021 3:52:21 PM ******/
CREATE TABLE [onprc_ehr].[Prima_UserPersons](
    [Id] [int] NOT NULL,
    [DateOfBirth] [datetime] NULL,
    [DepartmentName] [nvarchar](127) NULL,
    [FirstName] [nvarchar](31) NULL,
    [Gender] [tinyint] NOT NULL,
    [LastName] [nvarchar](31) NULL,
    [MiddleName] [nvarchar](31) NULL,
    [Prefix] [int] NULL,
    [SSN] [nvarchar](9) NULL,
    [ProfessionalTitles] [nvarchar](127) NULL,
    [DateOfDeath] [datetime] NULL
    )
;

--2. SurgicalWheel table
/****** Object:  Table [onprc_ehr].[Prima_SurgicalWheels]   Script Date: 6/17/2021 3:53:24 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SurgicalWheels](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Constant] [tinyint] NULL,
    [Description] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](5) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL
    )
;

--3. StainTests table
/****** Object:  Table [onprc_ehr].[Prima_StainTests]  Script Date: 6/17/2021 4:03:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_StainTests](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Abbreviation] [nvarchar](127) NOT NULL,
    [Constant] [tinyint] NULL,
    [CptCode] [nvarchar](6) NULL,
    [Description] [nvarchar](255) NULL,
    [StainTestCategoryId] [int] NOT NULL,
    [TimeLength] [int] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](127) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL,
    [IsValidated] [bit] NOT NULL
    )
;

--4. Slidebases table
/****** Object:  Table [onprc_ehr].[Prima_SlideBases]   Script Date: 6/17/2021 4:04:46 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [HandStain] [bit] NOT NULL,
    [IsCharged] [bit] NOT NULL,
    [StainTestId] [int] NOT NULL,
    [DilutionFactor] [int] NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL,
    [FreeTextNotes] [nvarchar](4000) NULL
    )
;

--5. CaseBase table
/****** Object:  Table [onprc_ehr].[Prima_CaseBase]  Script Date: 6/17/2021 4:07:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CaseBase](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [DifferentialDiagnosisId] [int] NULL,
    [PathologistId] [int] NULL,
    [PriorityLevelId] [int] NOT NULL,
    [ResidentPathologistId] [int] NULL,
    [SerialNumber] [int] NOT NULL,
    [SurgeryDate] [datetime] NULL,
    [SurgicalWheelId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [ResearcherId] [int] NULL,
    [StudyId] [int] NULL,
    [Discriminator] [nvarchar](128) NULL,
    [StudyPhaseId] [int] NULL,
    [CohortId] [int] NULL,
    [SavedIdentifier] [nvarchar](max) NULL,
    [Status] [tinyint] NOT NULL,
    [AlternateIdentifier] [nvarchar](24) NULL
    )
;

--6. CassetteEvents table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEvents]  Script Date: 6/17/2021 4:08:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [TissueProcessorId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [CassetteBatchId] [int] NULL,
    [CassetteOrderId] [bigint] NULL,
    [AutomatedCassetteArchivalMachineId] [int] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [IsEstimated] [bit] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL
    )
;

--7. CassetteEventLocations table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEventLocations]  Script Date: 6/17/2021 4:09:55 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEventLocations](
    [CassetteEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

--8. CassetteBases table
/****** Object:  Table [onprc_ehr].[Prima_CassetteBases]  Script Date: 6/17/2021 4:10:42 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteColorId] [int] NOT NULL,
    [EmbeddingInstructionId] [int] NOT NULL,
    [EmbeddingNotes] [nvarchar](4000) NULL,
    [HasTissue] [bit] NOT NULL,
    [ProtocolCassetteId] [int] NULL,
    [SpecimenBaseId] [bigint] NOT NULL,
    [TissueCollectionId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [TissueQuantity] [smallint] NOT NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL
    )
;

--9. LabstationTypes table
/****** Object:  Table [onprc_ehr].[Prima_LabstationTypes]  Script Date: 6/17/2021 4:41:00 PM ******/
CREATE TABLE [onprc_ehr].[Prima_LabstationTypes](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [CanProcess] [int] NOT NULL,
    [Constant] [int] NULL,
    [Description] [nvarchar](255) NULL,
    [IsEnabled] [bit] NOT NULL,
    [Order] [int] NOT NULL,
    [Title] [nvarchar](127) NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] varchar(500) NOT NULL
    )
;

--10. SlideEvents table
/****** Object:  Table [onprc_ehr].[Prima_SlideEvents]  Script Date: 6/17/2021 4:42:08 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [SlideBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [CoverSlipperId] [int] NULL,
    [OvenId] [int] NULL,
    [OvenProgramId] [int] NULL,
    [SlideImagerId] [int] NULL,
    [SlideStainerId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [SlideBatchId] [int] NULL,
    [SlideOrderId] [bigint] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL,
    [EquipmentId] [int] NULL,
    [AutomatedSlideArchivalMachineId] [int] NULL
    )
;

--11. SlideEventsLocations table
/****** Object:  Table [onprc].[Prima_SlideEventLocations]  Script Date: 6/17/2021 4:43:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEventLocations](
    [SlideEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

GO

--Create the stored procedures for the SSRS reports
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Slide billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

Create Procedure [onprc_ehr].[PrimaSlideBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7 SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
    CASE
    WHEN Prima_userpersons.lastname IS NOT NULL THEN
    Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
    Prima_userpersons.middlename)
    ELSE 'Unassigned Pathologist'
END AS 'Pathologist',
    Prima_staintests.title AS 'Stain Test',
    sub2.slidecount AS 'Slide Count'
    FROM (SELECT surgicalwheelid,
    Prima_slidebases.staintestid,
    Prima_casebase.pathologistid,
    Count(*) AS SlideCount
    FROM (SELECT Min(Prima_slideevents.created) AS VerifyOrBarcodeEventTime,
    slidebaseid
    FROM Prima_slideevents JOIN Prima_SlideEventLocations
    ON Prima_slideeventlocations.SlideEventId = Prima_slideevents.id
    AND Prima_slideeventlocations.LabStationTypeId = @staining WHERE eventtype = @complete
    GROUP BY slidebaseid) sub
    JOIN Prima_slidebases
    ON slidebaseid = Prima_slidebases.id
    JOIN Prima_casebase
    ON Prima_casebase.id = Prima_slidebases.casebaseid WHERE sub.verifyorbarcodeeventtime >= @startDate
    AND sub.verifyorbarcodeeventtime < @endDate
    GROUP BY surgicalwheelid,
    pathologistid,
    staintestid) sub2
    LEFT JOIN Prima_userpersons
    ON Prima_userpersons.id = sub2.pathologistid
    LEFT JOIN Prima_surgicalwheels
    ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    LEFT JOIN Prima_staintests
    ON Prima_staintests.id = sub2.staintestid
    ORDER BY 'Surgical Wheel',
    'Pathologist',
    'Stain Test'
END

GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Block billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

CREATE Procedure [onprc_ehr].[PrimaBlockBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7

SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
        CASE
            WHEN Prima_userpersons.lastname IS NOT NULL THEN
                Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
                       Prima_userpersons.middlename)
            ELSE 'Unassigned Pathologist'
            END AS 'Pathologist',
        sub2.cassettecount AS 'Cassette Count'
FROM (SELECT surgicalwheelid,
             Prima_casebase.pathologistid,
             Count(*) AS CassetteCount
      FROM (SELECT Min(Prima_cassetteevents.created) AS VerifyOrBarcodeEventTime,
                   cassettebaseid
            FROM Prima_cassetteevents
                     JOIN Prima_CassetteEventLocations
                          ON Prima_CassetteEventLocations.CassetteEventId = Prima_cassetteevents.id
                              AND Prima_CassetteEventLocations.LabStationTypeId = @embedding WHERE eventtype = @complete
            GROUP BY cassettebaseid) sub
               JOIN Prima_cassettebases
                    ON cassettebaseid = Prima_cassettebases.id
               JOIN Prima_casebase
                    ON Prima_casebase.id = Prima_cassettebases.casebaseid
      WHERE sub.verifyorbarcodeeventtime >= @startDate
        AND sub.verifyorbarcodeeventtime < @endDate
      GROUP BY surgicalwheelid,
               pathologistid) sub2
         LEFT JOIN Prima_userpersons
                   ON Prima_userpersons.id = sub2.pathologistid
         LEFT JOIN Prima_surgicalwheels
                   ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    ORDER BY 'Surgical Wheel',
         'Pathologist'
END

GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-17
-- Description:	Db tables creation for Prima reporting process. Created all the Prima tables in Prime onprc_ehr schema folder.
-- =======================================================================================================================================

--Drop if exists (Labkey syntax)
--Tables
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';
--Stored procs
EXEC core.fn_dropifexists 'PrimaSlideBillingReport', 'onprc_ehr', 'PROCEDURE';
EXEC core.fn_dropifexists 'PrimaBlockBillingReport', 'onprc_ehr', 'PROCEDURE';

GO

--Create tables
--1. UserPersons table
/****** Object:  Table [onprc_ehr].[Prima_UserPersons]  Script Date: 6/17/2021 3:52:21 PM ******/
CREATE TABLE [onprc_ehr].[Prima_UserPersons](
    [Id] [int] NOT NULL,
    [DateOfBirth] [datetime] NULL,
    [DepartmentName] [nvarchar](127) NULL,
    [FirstName] [nvarchar](31) NULL,
    [Gender] [tinyint] NOT NULL,
    [LastName] [nvarchar](31) NULL,
    [MiddleName] [nvarchar](31) NULL,
    [Prefix] [int] NULL,
    [SSN] [nvarchar](9) NULL,
    [ProfessionalTitles] [nvarchar](127) NULL,
    [DateOfDeath] [datetime] NULL
    )
;

--2. SurgicalWheel table
/****** Object:  Table [onprc_ehr].[Prima_SurgicalWheels]   Script Date: 6/17/2021 3:53:24 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SurgicalWheels](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Constant] [tinyint] NULL,
    [Description] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](5) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] [timestamp] NOT NULL
    )
;

--3. StainTests table
/****** Object:  Table [onprc_ehr].[Prima_StainTests]  Script Date: 6/17/2021 4:03:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_StainTests](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [Abbreviation] [nvarchar](127) NOT NULL,
    [Constant] [tinyint] NULL,
    [CptCode] [nvarchar](6) NULL,
    [Description] [nvarchar](255) NULL,
    [StainTestCategoryId] [int] NOT NULL,
    [TimeLength] [int] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](127) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] [timestamp] NOT NULL,
    [IsValidated] [bit] NOT NULL
    )
;

--4. Slidebases table
/****** Object:  Table [onprc_ehr].[Prima_SlideBases]   Script Date: 6/17/2021 4:04:46 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [HandStain] [bit] NOT NULL,
    [IsCharged] [bit] NOT NULL,
    [StainTestId] [int] NOT NULL,
    [DilutionFactor] [int] NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL,
    [FreeTextNotes] [nvarchar](4000) NULL
    )
;

--5. CaseBase table
/****** Object:  Table [onprc_ehr].[Prima_CaseBase]  Script Date: 6/17/2021 4:07:39 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CaseBase](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [DifferentialDiagnosisId] [int] NULL,
    [PathologistId] [int] NULL,
    [PriorityLevelId] [int] NOT NULL,
    [ResidentPathologistId] [int] NULL,
    [SerialNumber] [int] NOT NULL,
    [SurgeryDate] [datetime] NULL,
    [SurgicalWheelId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [ResearcherId] [int] NULL,
    [StudyId] [int] NULL,
    [Discriminator] [nvarchar](128) NULL,
    [StudyPhaseId] [int] NULL,
    [CohortId] [int] NULL,
    [SavedIdentifier] [nvarchar](max) NULL,
    [Status] [tinyint] NOT NULL,
    [AlternateIdentifier] [nvarchar](24) NULL
    )
;

--6. CassetteEvents table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEvents]  Script Date: 6/17/2021 4:08:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [TissueProcessorId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [CassetteBatchId] [int] NULL,
    [CassetteOrderId] [bigint] NULL,
    [AutomatedCassetteArchivalMachineId] [int] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [IsEstimated] [bit] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL
    )
;

--7. CassetteEventLocations table
/****** Object:  Table [onprc_ehr].[Prima_CassetteEventLocations]  Script Date: 6/17/2021 4:09:55 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteEventLocations](
    [CassetteEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

--8. CassetteBases table
/****** Object:  Table [onprc_ehr].[Prima_CassetteBases]  Script Date: 6/17/2021 4:10:42 PM ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteBases](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [CassetteColorId] [int] NOT NULL,
    [EmbeddingInstructionId] [int] NOT NULL,
    [EmbeddingNotes] [nvarchar](4000) NULL,
    [HasTissue] [bit] NOT NULL,
    [ProtocolCassetteId] [int] NULL,
    [SpecimenBaseId] [bigint] NOT NULL,
    [TissueCollectionId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [TissueQuantity] [smallint] NOT NULL,
    [CaseBaseId] [int] NOT NULL,
    [IsRadioActive] [bit] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [CurrentBatchId] [int] NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL
    )
;

--9. LabstationTypes table
/****** Object:  Table [onprc_ehr].[Prima_LabstationTypes]  Script Date: 6/17/2021 4:41:00 PM ******/
CREATE TABLE [onprc_ehr].[Prima_LabstationTypes](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [CanProcess] [int] NOT NULL,
    [Constant] [int] NULL,
    [Description] [nvarchar](255) NULL,
    [IsEnabled] [bit] NOT NULL,
    [Order] [int] NOT NULL,
    [Title] [nvarchar](127) NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] [timestamp] NOT NULL
    )
;

--10. SlideEvents table
/****** Object:  Table [onprc_ehr].[Prima_SlideEvents]  Script Date: 6/17/2021 4:42:08 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEvents](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
    [SlideBaseId] [bigint] NOT NULL,
    [EventType] [tinyint] NOT NULL,
    [Status] [smallint] NOT NULL,
    [Trigger] [tinyint] NOT NULL,
    [UserId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [EventAction] [int] NULL,
    [CoverSlipperId] [int] NULL,
    [OvenId] [int] NULL,
    [OvenProgramId] [int] NULL,
    [SlideImagerId] [int] NULL,
    [SlideStainerId] [int] NULL,
    [Discriminator] [nvarchar](128) NOT NULL,
    [SlideBatchId] [int] NULL,
    [SlideOrderId] [bigint] NULL,
    [DisposalReasonId] [int] NULL,
    [ShipmentId] [int] NULL,
    [PrintCount] [int] NULL,
    [BarcodeContent] [nvarchar](max) NULL,
    [EquipmentId] [int] NULL,
    [AutomatedSlideArchivalMachineId] [int] NULL
    )
;

--11. SlideEventsLocations table
/****** Object:  Table [onprc].[Prima_SlideEventLocations]  Script Date: 6/17/2021 4:43:57 PM ******/
CREATE TABLE [onprc_ehr].[Prima_SlideEventLocations](
    [SlideEventId] [bigint] NOT NULL,
    [LabStationTypeId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [WorkstationId] [int] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [PersonId] [int] NULL
    )
;

GO

--Create the stored procedures for the SSRS reports
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Slide billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

Create Procedure [onprc_ehr].[PrimaSlideBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7 SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
    CASE
    WHEN Prima_userpersons.lastname IS NOT NULL THEN
    Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
    Prima_userpersons.middlename)
    ELSE 'Unassigned Pathologist'
END AS 'Pathologist',
    Prima_staintests.title AS 'Stain Test',
    sub2.slidecount AS 'Slide Count'
    FROM (SELECT surgicalwheelid,
    Prima_slidebases.staintestid,
    Prima_casebase.pathologistid,
    Count(*) AS SlideCount
    FROM (SELECT Min(Prima_slideevents.created) AS VerifyOrBarcodeEventTime,
    slidebaseid
    FROM Prima_slideevents JOIN Prima_SlideEventLocations
    ON Prima_slideeventlocations.SlideEventId = Prima_slideevents.id
    AND Prima_slideeventlocations.LabStationTypeId = @staining WHERE eventtype = @complete
    GROUP BY slidebaseid) sub
    JOIN Prima_slidebases
    ON slidebaseid = Prima_slidebases.id
    JOIN Prima_casebase
    ON Prima_casebase.id = Prima_slidebases.casebaseid WHERE sub.verifyorbarcodeeventtime >= @startDate
    AND sub.verifyorbarcodeeventtime < @endDate
    GROUP BY surgicalwheelid,
    pathologistid,
    staintestid) sub2
    LEFT JOIN Prima_userpersons
    ON Prima_userpersons.id = sub2.pathologistid
    LEFT JOIN Prima_surgicalwheels
    ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    LEFT JOIN Prima_staintests
    ON Prima_staintests.id = sub2.staintestid
    ORDER BY 'Surgical Wheel',
    'Pathologist',
    'Stain Test'
END

    GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-06-15
-- Description:	This stored procedure creates the Prima Block billing report for the specified date range.
--				This proc is used to create the SSRS report.
-- =======================================================================================================================================

CREATE Procedure [onprc_ehr].[PrimaBlockBillingReport]
    @startDate smalldatetime,
    @endDate smalldatetime

AS

DECLARE
@staining int,
@embedding int,
@complete int

BEGIN
    --SET @startDate = '2000-01-01' -- 00:00:00.0000000 -07:00'
    --SET @endDate = '2021-05-31' -- 00:00:00.0000000 -07:00'
SET @staining = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 10)
SET @embedding = (SELECT id FROM Prima_LabstationTypes WHERE Constant = 7)
SET @complete = 7

SELECT Prima_surgicalwheels.title AS 'Surgical Wheel',
        CASE
            WHEN Prima_userpersons.lastname IS NOT NULL THEN
                Concat(Prima_userpersons.lastname, ', ', Prima_userpersons.firstname, ' ',
                       Prima_userpersons.middlename)
            ELSE 'Unassigned Pathologist'
            END AS 'Pathologist',
        sub2.cassettecount AS 'Cassette Count'
FROM (SELECT surgicalwheelid,
             Prima_casebase.pathologistid,
             Count(*) AS CassetteCount
      FROM (SELECT Min(Prima_cassetteevents.created) AS VerifyOrBarcodeEventTime,
                   cassettebaseid
            FROM Prima_cassetteevents
                     JOIN Prima_CassetteEventLocations
                          ON Prima_CassetteEventLocations.CassetteEventId = Prima_cassetteevents.id
                              AND Prima_CassetteEventLocations.LabStationTypeId = @embedding WHERE eventtype = @complete
            GROUP BY cassettebaseid) sub
               JOIN Prima_cassettebases
                    ON cassettebaseid = Prima_cassettebases.id
               JOIN Prima_casebase
                    ON Prima_casebase.id = Prima_cassettebases.casebaseid
      WHERE sub.verifyorbarcodeeventtime >= @startDate
        AND sub.verifyorbarcodeeventtime < @endDate
      GROUP BY surgicalwheelid,
               pathologistid) sub2
         LEFT JOIN Prima_userpersons
                   ON Prima_userpersons.id = sub2.pathologistid
         LEFT JOIN Prima_surgicalwheels
                   ON Prima_surgicalwheels.id = sub2.surgicalwheelid
ORDER BY 'Surgical Wheel',
         'Pathologist'
END

    GO

EXEC core.fn_dropifexists 'ASB_SpecialInstructions','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[ASB_SpecialInstructions]   Script Date: 6/14/21 ******/
CREATE TABLE [onprc_ehr].[ASB_SpecialInstructions](
    [value] [nvarchar](1000) NOT NULL,
    [remarks] [nvarchar](2000) NULL,
    [dateDisabled] [datetime] NULL,
    [created] [datetime] NULL,
    [createdBy] [int] NULL,
    [modified] [datetime] NULL,
    [modifiedBy] [int] NULL

    CONSTRAINT pk_ASB_SpecialInstructions PRIMARY KEY (value)
    )

    GO

EXEC core.fn_dropifexists 'StudyDetails_RandalData','onprc_ehr','TABLE';
GO

/****** Object:  Table [onprc_ehr].[StudyDetails_RandalData]    Script Date: 10/13/2021
Purpose Target for import from external datasource mfsh
******/

CREATE TABLE [onprc_ehr].[StudyDetails_RandalData](
    [id]  INT NOT NULL,
    [Rh] [nvarchar](100) NULL,
    [Cohort] [nvarchar](1000) NULL,
    [PI] [nvarchar](100) NULL,
    [Cohort_id] INT NULL,
    [subcohort] [nvarchar](100) NULL,
    [grp] [nvarchar](100) NULL,
    [grp_order] INT NULL,
    [grp_id] INT NOT NULL,
    [rhCode] [nvarchar](100) NULL,
    [grpnm] INT NULL,
    [Sex] [nvarchar](100) NULL,
    [cohortStart] [date]  null,
    [cohortEnd] [date]  null,
    [Do] [date]  null,
    [DPC0] [date]  null,
    [contprog] [nvarchar](100) NULl,
    [PIDO] date  null,
    [DPTO] date Null,
    [Birth] date null,
    [Nx_date] date null,
    [stims] [nvarchar](100) NULl,
    [active] [nvarchar](100) NULl
 CONSTRAINT pk_StudyDetails_Randal PRIMARY KEY (Id)
    )





    GO

EXEC core.fn_dropifexists 'BSUageclass','onprc_ehr','TABLE';
GO


CREATE TABLE [onprc_ehr].[BSUageclass]
(
    [rowId]  INT IDENTITY(1,1)NOT NULL,
    label varchar(255) NULL,
    species varchar(255) NULL,
    gender varchar(5) NULL,
    ageclass INT NULL,
    min [float] NULL,
    max [float] NULL,
    [sort_order] INT NULL,
    [dateDisabled] [datetime] NULL,

    CONSTRAINT PK_bsuageclass PRIMARY KEY (rowId)

    )
    GO

/* 22.xxx SQL scripts */

-- This stored procedure was incorrectly named and placed in the wrong schema when created in onprc_ehr-18.10-20.101.sql.
-- It's also unused, so just drop it.
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND object_id = OBJECT_ID('[dbo].[onprc_ehr.etlStep1eIACUCtoPRIMEProcessing]'))
    DROP PROCEDURE [dbo].[onprc_ehr.etlStep1eIACUCtoPRIMEProcessing]

--added to allow department descignation for R & L
EXEC core.fn_dropifexists 'Investigators', 'onprc_ehr', 'COLUMN', 'Department';
GO
ALTER TABLE onprc_ehr.investigators ADD [Department] varchar(250) Null;

/* 23.xxx SQL scripts */

CREATE TABLE [onprc_ehr].[Epoc_tests]
(
    rowid  INT IDENTITY(1,1)NOT NULL,
    testid nvarchar(500) NOT NULL,
    name nvarchar(500) NULL,
    units nvarchar(50) NULL,
    alias nvarchar(200) NULL,
    alertOnAbnormal  [bit] NULL,
    alertOnAny [bit] NULL,
    includeInPanel [bit]NULL,
    objectid  ENTITYID NOT NULL,
    sort_order [int] NULL,
    container ENTITYID

    CONSTRAINT PK_EpocTestsObject PRIMARY KEY (objectid)

    )
    GO

CREATE TABLE onprc_ehr.Reference_Data_IDkey
(
        rowId int identity(1,1),
        displayName varchar(4000) DEFAULT NULL,
        idkey       integer NOT NULL,
        columnName  varchar(1000)  NOT NULL,
        status      integer NULL,
        type        varchar(500) NULL,
        sort_order  integer  null,
        created     datetime NOT NULL,
        endDate     datetime  DEFAULT NULL


         CONSTRAINT pk_referenceIDkey PRIMARY KEY (idkey)
)


GO


-- Author:	R. Blasa
-- Created: 10-10-2022
-- Description:	Stored procedure program to initially populate onprc_ehr.Reference_Data_IDkey.


Create Procedure [onprc_ehr].[p_PopulateReferenceDataIDkey]


AS


BEGIN
                 ---- Reset lookiup table

              truncate table onprc_ehr.Reference_Data_IDkey

                 ----- Create initial entries
                   Insert into  onprc_ehr.Reference_Data_IDkey
                    select

                           Name,
                           UserId,
                           'Active_Groups',
                           Active,
                           Type,
                           NULL as sort_order,    ---- Sort_Order
                           GETDATE() as created,   ----- Created
                           NULL as enddate     ----- Date Disabled

            FROM core.Principals
                        where type = 'g'
                        and UserId > 0
                        and Active = 1
                        and Container is null

                        If @@Error <> 0
   			      	 GoTo Err_Proc


              Return 0

Err_Proc:    Return 1

END

GO

-- Created: 10-10-2022  R. Blasa to correct type definitionss


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN createdby userid;
GO


ALTER TABLE onprc_ehr.encounter_summaries_remarks ALTER COLUMN modifiedby userid;
GO

CREATE TABLE [onprc_ehr].[PrimeProblemListTemp](
    [rowid] [int] IDENTITY(100,1) NOT NULL,
    [animalid] [varchar](200) NULL,
    [date] datetime NULL,
    [objectid] [varchar](4000) NULL,
    [caseid] [varchar](4000) NULL,
    [case_enddate] datetime,
    [created]  datetime


    )
    GO



-- Author:	R. Blasa
-- Created: 10-20-2022
-- Description:	Stored procedure program assigns Clinical Cases ending dates to all Clinical Problem list that
--               have no ending dates, and shares the same case ids


CREATE Procedure [onprc_ehr].[p_CaseToPRoblemListupdates]




AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TempObjectID           varchar(4000),
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @CaseEnddate            datetime,
			  @SessionID              Int




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.PrimeProblemListTemp


    If @@Error <> 0
	  GoTo Err_Proc



    --- Generate a list of Problem List records to close                         )

   Insert into onprc_ehr.PrimeProblemListTemp

    select
    b.participantid,
    b.date,
    b.objectid,
    b.caseid,
    a.enddate ,------ case ending date
    getdate()   ------ date created


     from studyDataset.c6d176_cases a, studyDataset.c6d200_problem b
    where a.objectid = b.caseid
    and a.category in ('clinical','Behavior')
    and a.qcstate = 18 and b.qcstate = 18
    and b.enddate is null
    and a.enddate is not null
    and a.participantid = b.participantid
      order by a.date desc


    If @@Error <> 0
	  GoTo Err_Proc


    ---- Reset temp variables

Set @SearchKey = 0
Set @TempSearchKey = 0
Set @TempObjectid  = NULL
Set @CaseEnddate  = NULL

----- extract initial row id

Select Top 1 @Searchkey = rowid  from onprc_ehr.PrimeProblemListTemp
Order by rowid


    While @TempSearchKey < @SearchKey
    BEGIN

                    -----Begin update process

           If exists (select * from onprc_ehr.PrimeProblemListTemp  Where rowid = @SearchKey)
            BEGIN

                 Select @TempObjectid =objectid, @CaseEnddate = case_enddate  from onprc_ehr.PrimeProblemListTemp
                  Where rowid = @Searchkey

                      -------Begin record editing process

                              Update prob
                              set prob.enddate = @CaseEnddate
                              From studyDataset.c6d200_problem prob
                              where prob.objectid = @TempObjectID


                                   If @@Error <> 0
                                    GoTo Err_Proc
            END


                    ----- Proceed and fetch the next record

                     Set @TempSearchKey = @SearchKey

                  Select Top 1 @SearchKey = rowid from onprc_ehr.PrimeProblemListTemp
                     Where rowid > @TempSearchKey
                      Order by rowid


    END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

              Select * into onprc_ehr.PrimeProblemListMaster
                  from onprc_ehr.PrimeProblemListTemp
                      If @@Error <> 0
	  			               GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO

---Create 5-2023-08-15 jonesga

EXEC core.fn_dropifexists 'PrimeProblemListTemp', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'PrimeProblemListMaster', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'p_CaseToPRoblemListupdates', 'onprc_ehr', 'PROCEDURE', NULL;
GO

-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Stored procedure program to allow cage status settings to be updated by default to "Normal".


CREATE Procedure [onprc_ehr].[p_CageStatusupdates]

AS

BEGIN

If exists (select * from ehr_lookups.cage)
  BEGIN
    --- Set Cage status to Normal                       )

     Update ehr_lookups.cage
          Set status = 'Normal'
         Where status is null


    If @@Error <> 0
	  GoTo Err_Proc

END

 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO


-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Temp table for cage information audit history.

CREATE TABLE [onprc_ehr].[CageAuditLog](
    [searchid] [int] IDENTITY(100,1) NOT NULL,
    [rowid] [int] NULL,
    [location] [nvarchar](100) NULL,
    [room] [varchar](200) NULL,
    [cage] [varchar](200) NULL,
    [divider] [int] NULL,
    [cage_type] [varchar](100) NULL,
    [hasTunnel] [bit] NULL,
    [status] [varchar](200) NULL,
    [Container] [dbo].[ENTITYID] NOT NULL,
    [area] [varchar](500) NULL,
    [housingtype] [varchar](500) NULL,
    [housingcondition] [varchar](500) NULL,
    [date_created] [smalldatetime] NULL
    ) ON [PRIMARY]

    GO










-- Author:	R. Blasa
-- Created: 8-30-2023
-- Description:	Stored procedure program to provide historical cage information audit history.


CREATE Procedure [onprc_ehr].[p_CageAuditHistoryProcess]

AS


BEGIN

    --- Create historical cage data
If exists (select * from onprc_ehr.CageAuditLog)
BEGIN
Insert into onprc_ehr.CageAuditLog
Select  rowid,
        a.location,
        a.room,
        a.cage,
        a.divider,
        a.cage_type,
        a.hasTunnel,
        a.status,
        a.container,
        (select h.area from ehr_lookups.rooms h where h.room = a.room) as area,
        (select s.value from ehr_lookups.rooms h, ehr_lookups.lookups s where h.room = a.room and s.rowid = h.housingtype) as housingtype,
        (select s.value from ehr_lookups.rooms h, ehr_lookups.lookups s  where h.room = a.room and s.rowid = h.housingcondition) as housingcondition,
        getdate()

from ehr_lookups.cage a

    If @@Error <> 0
	  GoTo Err_Proc

END  --- if exists

 RETURN 0


Err_Proc:
                    -------Error Generated
	RETURN 1


END

GO

ALTER TABLE onprc_ehr.CageAuditLog ADD CONSTRAINT pk_searchid PRIMARY KEY (searchid);

-- =================================================================================================
-- Add MPA Clinical remarks: By, Lakshmi Kolli
-- Created on: 1/25/2024
/* Description: Created 1 temp table to store the clinical remarks records.
 The stored proc manages the addition and deleting clinical remarks data from the temp table
 at the time of execution via ETL process.
 */
-- =================================================================================================

--Drop table if exists
EXEC core.fn_dropifexists 'Temp_ClnRemarks','onprc_ehr','TABLE';
--Drop Stored proc if exists
EXEC core.fn_dropifexists '[onprc_ehr].[MPA_ClnRemarkAddition]', 'onprc_ehr', 'PROCEDURE';
GO

-- Create the temp table
CREATE TABLE onprc_ehr.Temp_ClnRemarks
(
    date datetime,
    qcstate int,
    participantid nvarchar(32),
    project int,
    remark nvarchar(250) ,
    p nvarchar(250) ,
    performedby nvarchar(250) ,
    category nvarchar(250) ,
    taskid nvarchar(4000),
    createdby int,
    modifiedby int
)
;

GO

-- Create the stored proc
/****** Object:  StoredProcedure [onprc_ehr].[MPA_ClnRemarkAddition]    Script Date: 1/25/2024 *****/
-- =================================================================================
 -- Author: Lakshmi Kolli
 -- Create date: 1/25/2024
 -- Description: This procedure identifies if an animal received an MPA injection
 -- and inserts a clinical remark into animal's record.
-- =================================================================================

CREATE PROCEDURE [onprc_ehr].[MPA_ClnRemarkAddition]
AS

DECLARE
@MPACount Int,
	@taskId	  nvarchar(4000)

BEGIN
    --Delete all rows from the temp_Drug table
    Delete From onprc_ehr.Temp_ClnRemarks

    --Check if the MPA injection E-85760 was administered today
    Select @MPACount = COUNT(*) From studyDataset.c6d178_drug
    Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

    --Found entries, so, enter the clinical remarks now
    If @MPACount > 0
    Begin
        -- Create a Task entry in ehr.tasks table
        Set @taskid = NEWID() -- creating taskid
        Insert Into ehr.tasks
        (taskid, category, title, formtype, qcstate, assignedto, duedate, createdby, created,
         container, modifiedby, modified, description, datecompleted)
        Values
        (@taskid, 'Task', 'Bulk Clinical Entry', 'Bulk Clinical Entry', 18, 1003, GETDATE(), 1003, GETDATE(),
         'CD17027B-C55F-102F-9907-5107380A54BE', 1003, GETDATE(), 'Created by the ETL process', GETDATE())

        --Insert the clinical remark into the temp clinical remarks table.
        /* Get all the Animals who had MPA injection today from studyDataset.c6d178_drug
        and INSERT the data into the studyDataset.c6d185_clinremarks table */
        Insert Into onprc_ehr.Temp_ClnRemarks (
        date, qcstate, participantid, project, remark, p, performedby, category, taskid, createdby, modifiedby
        )
        Select GETDATE(), 18, participantid, project, 'Remark entered by the ETL process', 'MPA injection administered', 'onprcitsupport@ohsu.edu', 'Clinical', @taskId, 1003, 1003
        From studyDataset.c6d178_drug
        Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18
    End

END

GO

CREATE TABLE onprc_ehr.Environmental_Reference_Data (
        rowId int identity(1,1),
        label varchar(250) DEFAULT NULL,
        value varchar(500) ,
        columnName varchar(255)  NOT NULL,
        sort_order integer  null,
        endDate  datetime  DEFAULT NULL,

        CONSTRAINT pk_referenceenv PRIMARY KEY (value)
)


    GO

CREATE TABLE onprc_ehr.Environmental_Assessment(
           rowid int IDENTITY(100,1) NOT NULL,
           date datetime NULL,
           service_requested varchar(300) NULL,
           charge_unit varchar(300) NULL,
           testing_location  varchar(300) NULL,
           test_type  varchar(300) NULL,
           test_results  varchar(100) NULL,
           pass_fail  varchar(100) NULL,
           biological_Cycle  varchar(300) NULL,
           biological_BI  varchar(300) NULL,
           action  varchar(300) NULL,
           performedby  varchar(300) NULL,
           remarks  varchar(300) NULL,
           water_source  varchar(300) NULL,
           surface_tested  varchar(300) NULL,
           retest  varchar(300) NULL,
           colony_count  varchar(300) NULL,
           test_method  varchar(300) NULL,
           objectid ENTITYID Not Null,
           createdby int NULL,
           created datetime NULL,
           modifiedby int NULL,
           modified datetime NULL,
           Container ENTITYID NOT NULL,
           taskid  entityid,
           qcstate int NULL,
           formsort int NULL


               CONSTRAINT PK_assessment PRIMARY KEY (objectid)
)

    GO

/*
**
** 	Created by 		Date
**
**      Blasa  		      4-5-2024  Process to update Environmental Assessment data set  ldk file from Production database.
**
**
**
*/


CREATE Procedure onprc_ehr.p_Environmental_Update_Process



    AS


BEGIN

    IF exists (Select * from [list].[c8754d723_surface_sanitation_minus_rodac_48hr])
BEGIN


Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,   ----TestSite
 service_requested,
 test_type,     ------TestType
 colony_count,   ---ColonyCount     Before: test_resuls
 pass_fail,      -----PassFail
 performedby,    ------Collectedby
 action,         ----Action
 remarks,       ----comments
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    TestSite,
    'Sanitation: Contact Plate' ,
    TestType,
    ColonyCount,
    PassFail,
    CollectedBy,
    Action,
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from [list].[c8754d723_surface_sanitation_minus_rodac_48hr]



    If @@Error <> 0
    GoTo Err_Proc
END -----



    IF exists (Select * from [list].[c8754d726_h2o_testing])
BEGIN

Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,  ---testing Location
 service_requested,
 water_source,     ----H2OSource,
 test_type,          ----- Testtype
 test_results,          ----result
 pass_fail,             ----PassFail
 remarks,
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    TestSite,
    'Sanitation: Water Test',
    H2OSource,
    TestType,
    result,
    PassFail,
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from [list].[c8754d726_h2o_testing]

    If @@Error <> 0
    GoTo Err_Proc
END -----

     IF exists (Select * from list.c8754d795_biological_indicator_log)
BEGIN

Insert into  onprc_ehr.Environmental_Assessment

(date,
 testing_location,     ---autoclave
 service_requested,
 biological_Cycle,    ----cycle (if applicable)
 biological_BI,     ----BI# (for ASA)
 pass_fail,         ---Pass / Fail
 retest ,   ----Results Read by        Before: test_results
 action,    ----- action
 performedby,       ----collected by
 remarks,
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select date,
    autoclave,
    'Sanitation: Bio-indicator',
    [cycle (if applicable)],
    [BI# (for ASA)],
    [Pass / Fail],
    [Results Read by],
    action,
    [Collected By],
    comment,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'

from list.c8754d795_biological_indicator_log

    If @@Error <> 0
    GoTo Err_Proc
END -----


    IF exists (Select * from list.c8754d731_atp_testing)
BEGIN

    ---- Note:  ATP Testing is strictly Kati's entries only


Insert into  onprc_ehr.Environmental_Assessment

(date,
 performedby,         ---tech inititals
 service_requested,
 testing_location,              ----Area
 surface_tested,    --- Surface    column before -->biological_reader
 pass_fail,          --- initial
 remarks,           ---comments
 retest,         ----retest   column before---->water_source
 test_results,        -------Lab/Group
 action	,           -----location
 objectid,
 created,
 createdby,
 modified,
 modifiedby,
 qcstate,
 container)

select    date,
    Tech_Initials,
    'Sanitation: ATP',
    area,
    Surface,
    initial,
    comments,
    retest,
    Lab_Group,
    location,
    newid(),
    getdate(),
    1896,
    getdate(),
    1896,
    18,
    '98F39B23-5E3B-1037-AFE5-BD25D057100A'
from list.c8754d731_atp_testing

    If @@Error <> 0
    GoTo Err_Proc
END -----




RETURN 0


    Err_Proc:
         RETURN 1

END

    GO






/*
**
** 	Created by 		Date
**
**      Blasa  		      4-5-2024  Process to update Environmental Assessment data set  ldk file from Production database.
**
**
**
*/


CREATE Procedure onprc_ehr.p_EnvironmentalHistoricalUpdates



    AS


BEGIN

IF exists (Select * from onprc_ehr.Environmental_Assessment)
BEGIN
---Update Testing location syntax

Update ss
set ss.testing_location = 'COL SW'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. SW'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 1',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Annex Rm 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL SW',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony SW'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Catch Area 2',
    ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 2'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 1 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 10 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 10'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 11 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 11'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 12 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 12'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 2 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 3 Lixit'

    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 3'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 4 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 4'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 5 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 5'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 6 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 6'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Pens Run 7 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 7'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 8 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 8'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Pens Run 9 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Pens Run 9'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 1 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 10 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 10'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 11 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 11'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 12 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 12'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 13 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 13'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 14 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 14'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 15 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 15'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 16 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 16'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 17 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 17'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 18 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 18'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 19 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 19'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 2 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 20 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 20'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 21 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 21'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 22 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 22'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 23 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 23'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 24 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 24'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 25 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 25'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 26 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 26'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 27 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 27'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 28 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 28'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 3 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 3'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 31 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 31'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 32 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 32'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 4 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 4'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 5 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 6 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 6'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 7 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 7'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 8 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 8'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 9 Lixit'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 9'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 102'

    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 102'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 103'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 103'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 104'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 104'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 122'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 122'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'BOS RM 123'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Bosky 123'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Cage Washer Colony Annex toy'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer Colony Annex tunnel toy'



    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Cage Washer VGTI Large (Jan/June)'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer VGTI Large (semi-annual)'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Cage Washer VGTI Small (Jan/June)'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Cage Washer VGTI Small (semi-annual)'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Dishwasher Colony North'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Dishwasher N. Colony'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Dishwasher Colony South'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Dishwasher S. Colony'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 37'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Annex room 37'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Catch Area 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Catch Area 5'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Catch 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL SW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. SW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL NW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col. NW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL NW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony NW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL RM 4'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony RM 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 1'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 2'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 3'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 3'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 4'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'COL Run 5'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony Run 5'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
      set ss.testing_location = 'COL Run 6'
          -- ss.charge_unit = 'Clinpath'
          from onprc_ehr.Environmental_Assessment ss
      where ss.testing_location = 'Colony Run 6'


                      If @@Error <> 0
                      GoTo Err_Proc
    Update sS
    set ss.testing_location = 'COL Run 7'
            -- ss.charge_unit = 'Clinpath'
            from onprc_ehr.Environmental_Assessment ss
        where ss.testing_location = 'Colony Run 7'


                        If @@Error <> 0
                        GoTo Err_Proc

    Update ss
          set ss.testing_location = 'COL Run 8'
              -- ss.charge_unit = 'Clinpath'
              from onprc_ehr.Environmental_Assessment ss
          where ss.testing_location = 'Colony Run 8'

              If @@Error <> 0
              GoTo Err_Proc


Update ss
set ss.testing_location = 'COL SW'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Colony SW'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1  inside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 1'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 1 inside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'SGH 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2  outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 2'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 2 outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29  inside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 29'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 29 inside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30  outside'

    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'SGH 30'
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30 outside'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Dishwasher Bldg 611 '
    -- ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'SGH 30 outside'

    If @@Error <> 0
    GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher ASA 135'
where testing_location = 'Dishwasher ASA 135 '


    If @@Error <> 0
	    GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher ASA 136'
where testing_location = 'Dishwasher ASA 136 '

    If @@Error <> 0
	      GoTo Err_Proc

update onprc_ehr.Environmental_Assessment
set testing_location = 'Dishwasher Bldg 611'
where testing_location = 'Dishwasher Bldg 611 '


    If @@Error <> 0
	      GoTo Err_Proc

Update ss
set ss.testing_location = 'Annex Rm 1'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 1'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 34'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 34'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 13'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 13'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 14'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 14'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 15'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 15'


    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 16'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 16'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 2'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 2'

    If @@Error <> 0
    GoTo Err_Proc


Update ss
set ss.testing_location = 'Annex Rm 34'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 34'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Rm 39'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 39'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Rm 4'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RM 4'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
      set ss.testing_location = 'Annex Run 1'
          from onprc_ehr.Environmental_Assessment ss
      where ss.testing_location = 'AN RUN 1'


          If @@Error <> 0
          GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 2'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 2'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 3'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 3'


    If @@Error <> 0
    GoTo Err_Proc
Update ss
set ss.testing_location = 'Annex Run 30'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'AN RUN 30'


    If @@Error <> 0
    GoTo Err_Proc

Update ss
set ss.testing_location = 'Col Run 7E'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location = 'Col Run 7 E'

    If @@Error <> 0
    GoTo Err_Proc

------ Update only locations designated as Clinpath locations.

Update ss
set ss.charge_unit = 'Clinpath'
    from onprc_ehr.Environmental_Assessment ss
where ss.testing_location in (select distinct value from onprc_ehr.Environmental_Reference_Data where columnname = 'testlocation')

    If @@Error <> 0
    GoTo Err_Proc

----------- Update only locations designated as Kati's Room LocationXXXX

update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7A'
where testing_location = 'Col Run 7 A'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7B'
where testing_location = 'Col Run 7 B'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 7D'
where testing_location = 'Col Run 7 D'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Colony Rm 2 (Clinic)'
where testing_location = 'Colony Rm 2 Clinic'



    If @@Error <> 0
	          GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 102A  (Clinic)'
where testing_location = 'Pens Rm 102A (Clinic)'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 104 (Feed)'
where testing_location = 'PENS Rm 104 (Feed Room)'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Pens RM 104 (Feed)'
where testing_location = 'Pens RM 104 (Feed )'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'VGTI 0120 (clean cage wash)'
where testing_location = 'VGTI 0120 (clean cage wash'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 6A'
where testing_location = 'Col Run 6 A'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Col Run 6C'
where testing_location = 'Col Run 6 C'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'ASB 3 Cage Wash'
where testing_location = 'ASB 3 Cage Wash Area'



    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'ASB 1 Cage Wash'
where testing_location = 'ASB 1 Cage Wash Area'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer ASB 1 cage'
where testing_location = 'Cage Washer ASB 1'


    If @@Error <> 0
	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer VGTI Large (Jan/June)'
where testing_location = 'Cage Washer VGTI Large'



    If @@Error <> 0
 	                   GoTo Err_Proc
update onprc_ehr.Environmental_Assessment
set testing_location = 'Cage Washer VGTI Small (Jan/June)'
where testing_location = 'Cage Washer VGTI Small'


    If @@Error <> 0
	                   GoTo Err_Proc

END ----if exists



RETURN 0


    Err_Proc:
         RETURN 1

END

GO

-- Alter the stored proc
/****** Object:  StoredProcedure [onprc_ehr].[MPA_ClnRemarkAddition]  Script Date: 5/17/2024 *****/
-- =================================================================================
-- Author: Lakshmi Kolli
-- Create date: 5/17/2024
-- Description: Altering the procedure with the new ONPRC email address
-- =================================================================================

ALTER PROCEDURE [onprc_ehr].[MPA_ClnRemarkAddition]
AS

DECLARE
@MPACount       Int,
@taskId	        nvarchar(4000),
@displayName    nvarchar(250)

BEGIN
    --Delete all rows from the temp_Drug table
    Delete From onprc_ehr.Temp_ClnRemarks

    --Check if the MPA injection E-85760 was administered today
    Select @MPACount = COUNT(*) From studyDataset.c6d178_drug
    Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18

    --Found entries, so, enter the clinical remarks now
    If @MPACount > 0
    Begin
        -- Get the displayName for user: onprc-is from core.users table
        Select @displayName = displayName from core.users where userid = 1003

        -- Create a Task entry in ehr.tasks table
        Set @taskid = NEWID() -- creating taskid
        Insert Into ehr.tasks
        (taskid, category, title, formtype, qcstate, assignedto, duedate, createdby, created,
         container, modifiedby, modified, description, datecompleted)
        Values
        (@taskid, 'Task', 'Bulk Clinical Entry', 'Bulk Clinical Entry', 18, 1003, GETDATE(), 1003, GETDATE(),
         'CD17027B-C55F-102F-9907-5107380A54BE', 1003, GETDATE(), 'Created by the ETL process', GETDATE())

        --Insert the clinical remark into the temp clinical remarks table.
        /* Get all the Animals who had MPA injection today from studyDataset.c6d178_drug
        and INSERT the data into the studyDataset.c6d185_clinremarks table */
        Insert Into onprc_ehr.Temp_ClnRemarks (
        date, qcstate, participantid, project, remark, p, performedby, category, taskid, createdby, modifiedby
        )
        Select GETDATE(), 18, participantid, project, 'Remark entered by the ETL process', 'MPA injection administered', @displayName, 'Clinical', @taskId, 1003, 1003
        From studyDataset.c6d178_drug
        Where code = 'E-85760' And CONVERT(DATE, date) = CONVERT(DATE, GETDATE()) And qcstate = 18
    End
END

GO

CREATE TABLE [onprc_ehr].[TB_TestTemp](
    [rowid] [int] IDENTITY(100,1) NOT NULL,
     animalid      varchar(200) NULL,
     date          datetime NULL,
     objectid      ENTITYID NOT NULL,
     created       datetime NULL,
     createdby     integer NULL,
     performedby   varchar(200) NULL


    )
    GO

CREATE TABLE [onprc_ehr].[TB_TestTempMaster](
    rowid         integer ,
    animalid     varchar(200) NULL,
    date         datetime NULL,
    objectid     ENTITYID NOT NULL,
    created      datetime NULL,
    createdby    integer NULL,
    performedby  varchar(200) NULL


    )
    GO





/*
**
** 	Created by
**      R. Blasa   6-5-2024                 A  Program Process that reviews all TB Test entries on a given date, and creates a
**                                               new TB Test Clinical Observation record based on
**                                               having the same monkey id, date, and to be assigned to a Data Admin for reviews.
**
**
*/

CREATE Procedure onprc_ehr.p_Create_TB_Observationrecords



    AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @AnimalID               varchar(100),
              @date                   datetime,
              @createdby              smallint,
              @created                smalldatetime,
			  @performedby            varchar(200),
              @RunID                 varchar(4000)




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.TB_TestTemp


    If @@Error <> 0
	  GoTo Err_Proc


    --- Generate a list TB test monkeys                        )

     Insert into onprc_ehr.TB_TestTemp

select
    a.participantid,
    a.date,
    a.objectid,
    a.created,
    a.createdBy,
    a.performedby




from studydataset.c6d214_encounters  a
Where a.participantid not in (select b.participantid  from studydataset.c6d171_clinical_observations b
                              where a.participantid = b.participantid And cast(a.date as date)  = dateadd(day,3,cast(b.date as date))  And b.category = 'TB TST Score (72 hr)'  )
  And a.type = 'Procedure' And a.qcstate = 18 And procedureid = 802         -----'TB Test Intradermal'
  And a.created >=   dateadd(day, -1, cast(getdate() as date))
And a.participantid in ( select k.participantid from studydataset.c6d203_demographics k
    where k.calculated_status = 'alive')

order by a.participantid, a.date desc


    If @@Error <> 0
	 		 GoTo Err_Proc

        ---- When there are no records to process, exit immediately from the program.

     If (Select count(*) from onprc_ehr.TB_TestTemp) = 0

BEGIN
GOTO No_Records
END


    ---- Reset temp variables

          Set @SearchKey = 0
          Set @TempSearchKey = 0
          Set @Date = NULL
          Set @created = NULL
          Set @createdby =NULL
          Set @performedby = NULL
          Set @TaskID = NULL
          Set @Animalid = Null
          Set @RunID   = Null



      ----- extract initial row id

Select Top 1 @Searchkey = rowid  from onprc_ehr.TB_TestTemp
Order by rowid


    While @TempSearchKey < @SearchKey
BEGIN

                    -----Begin entry Tb observation process

Select @Animalid =animalid, @date = date, @created =created, @createdby =createdby,@performedby= performedby from onprc_ehr.TB_TestTemp Where rowid = @Searchkey

    If not exists (select * from studydataset.c6d171_clinical_observations j Where j.participantid  = @AnimalID
                                             And cast(j.date as date) = dateadd(day,3,cast(@date as date)) And j.category = 'TB TST Score (72 hr)'   )
BEGIN



                            Set @TaskID = NEWID()         ----- Task Record Object ID
                            Set @RunID = NEWID()          ---- ObjectID
                            Set @date = dateadd(day, 3,@date)  ----- Add three days from TB Test date



              ---- Generate a Task id record

                 Insert into EHR.Tasks
                   (
                    taskid,
                    description,
                    title,
                    qcstate,
                    formType,
                    category,
                    container,
                    assignedto,
                    created,
                    createdby,
                    modified,
                    modifiedby

                   )

	     Values  (

		   @TaskID,
		   @AnimalID + ' ' + cast(@Date as varchar(50)) ,   	        ------ Title  consist of animal id and Clinical procedure date
          'TB TST Scores',
		   20,                     	              --- Qc State (In Progress)
		   'TB TST Scores',              	      ------ FormType
		   'task',                 		      -----  category,
		  'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
		   1822,                               -------- Assigned To Data Admins
		   getdate(),                                ------- Create Date
		   @createdby, 				     -------- Created By
		   getdate(), 				     ------- Modified Date
		   @createdby				     ----- Modified by

                    )

					 If @@Error <> 0
	                                      GoTo Err_Proc



                       --- Create a Clinical Observation Record

                        Insert into studydataset.c6d171_clinical_observations
                                (
                                  participantid,
                                  date,
                                  category,
                                  area,
                                  observation,
                                  created,
                                  createdby,
                                  performedby,
                                  objectid,
								  taskid,
                                  qcstate,
								  modified,
								  modifiedby,
                                  lsid

                                   )
                              values (
                                  @animalid,
                                  @date,
                                  'TB TST Score (72 hr)',
                                 'Right Eyelid',
                                 'Grade: Negative',
                                  getdate(),                         ----- created
                                  @createdby,
                                  @performedby,
								   @RunID ,                                    ----- Objectid
                                   @TaskID,
                                    20 ,                                     ---- In Progress QCState
									getdate(),                         -----modified
									@createdBy,
                                    'urn:lsid:ohsu.edu:Study.Data-6:5006.10003.19810204.0000.' + '' + @RunID + ''

					)

					                 If @@Error <> 0
	                                      GoTo Err_Proc



END


             ----- Proceed and fetch the next record

                Set @TempSearchKey = @SearchKey

Select Top 1 @SearchKey = rowid from onprc_ehr.TB_TestTemp
Where rowid > @TempSearchKey
Order by rowid


END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

  Insert into onprc_ehr.TB_TestTempMaster
     Select *  from onprc_ehr.TB_TestTemp

         If @@Error <> 0
	  			GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, program processed stopped
	RETURN 1


END

GO

/*
**
** 	Created by
**      R. Blasa   6-5-2024                 A  Program Process that reviews all TB Test entries on a given date, and creates a
**                                               new TB Test Clinical Observation record based on
**                                               having the same monkey id, date, and to be assigned to a Data Admin for reviews.
**
**       R. Blasa                Modified program so that each Clinical Observation entries generated by the program is assigned
**                                only a single task id when the program executes daily.
**
**
*/

  ALTER Procedure onprc_ehr.p_Create_TB_Observationrecords



    AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @AnimalID               varchar(100),
              @date                   datetime,
              @createdby              smallint,
              @created                smalldatetime,
			  @performedby            varchar(200),
              @RunID                 varchar(4000)




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.TB_TestTemp


    If @@Error <> 0
	  GoTo Err_Proc


    --- Generate a list TB test monkeys                        )

     Insert into onprc_ehr.TB_TestTemp

select
    a.participantid,
    a.date,
    a.objectid,
    a.created,
    a.createdBy,
    a.performedby




from studydataset.c6d214_encounters  a
Where a.participantid not in (select b.participantid  from studydataset.c6d171_clinical_observations b
                              where a.participantid = b.participantid And cast(a.date as date)  = dateadd(day,3,cast(b.date as date))  And b.category = 'TB TST Score (72 hr)'  )
  And a.type = 'Procedure' And a.qcstate = 18 And procedureid = 802         -----'TB Test Intradermal'
  And a.created >=   dateadd(day, -1, cast(getdate() as date))
And a.participantid in ( select k.participantid from studydataset.c6d203_demographics k
    where k.calculated_status = 'alive')

order by a.participantid, a.date desc


    If @@Error <> 0
	 		 GoTo Err_Proc

        ---- When there are no records to process, exit immediately from the program.

    If (Select count(*) from onprc_ehr.TB_TestTemp) = 0
    BEGIN
    GOTO No_Records
    END


    ---- Reset temp variables

          Set @SearchKey = 0
          Set @TempSearchKey = 0
          Set @Date = NULL
          Set @created = NULL
          Set @createdby =NULL
          Set @performedby = NULL
          Set @TaskID = NULL
          Set @Animalid = Null
          Set @RunID   = Null



      ----- extract initial row id

        Select Top 1 @Searchkey = rowid  from onprc_ehr.TB_TestTemp
        Order by rowid


                    Set @TaskID = NEWID()         ----- Task Record Object ID

                    ----Create a single task for each daily process


                            Insert into EHR.Tasks
                        (
                            taskid,
                            description,
                            title,
                            qcstate,
                            formType,
                            category,
                            container,
                            assignedto,
                            created,
                            createdby,
                            modified,
                            modifiedby

                        )

                        Values  (

                            @TaskID,
                            'TB TST Scores ' + cast(@Date as varchar(50)) ,   	        ------ Title  consist of animal id and Clinical procedure date
                            'TB TST Scores',
                            20,                     	              --- Qc State (In Progress)
                            'TB TST Scores',              	      ------ FormType
                            'task',                 		      -----  category,
                            'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
                            1822,                               -------- Assigned To Data Admins
                            getdate(),                                ------- Create Date
                            1042, 				     -------- Created By IS
                            getdate(), 				     ------- Modified Date
                            1042				     ----- Modified by IS

                            )

                            If @@Error <> 0
                               GoTo Err_Proc



    While @TempSearchKey < @SearchKey
    BEGIN

                    -----Begin entry Tb observation process

       Select @Animalid =animalid, @date = date, @created =created, @createdby =createdby,@performedby= performedby from onprc_ehr.TB_TestTemp Where rowid = @Searchkey

    If not exists (select * from studydataset.c6d171_clinical_observations j Where j.participantid  = @AnimalID
                                             And cast(j.date as date) = dateadd(day,3,cast(@date as date)) And j.category = 'TB TST Score (72 hr)'   )
    BEGIN



               ----- Initialize data entries
                Set @RunID = NEWID()          ---- ObjectID
                Set @date = dateadd(day, 3,@date)  ----- Add three days from TB Test date



               --- Create a Clinical Observation Record

                Insert into studydataset.c6d171_clinical_observations
                        (
                          participantid,
                          date,
                          category,
                          area,
                          observation,
                          created,
                          createdby,
                          performedby,
                          objectid,
                          taskid,
                          qcstate,
                          modified,
                          modifiedby,
                          lsid

                           )
                      values (
                          @animalid,
                          @date,
                          'TB TST Score (72 hr)',
                         'Right Eyelid',
                         'Grade: Negative',
                          getdate(),                         ----- created
                          @createdby,
                          @performedby,
                           @RunID ,                                    ----- Objectid
                           @TaskID,
                            20 ,                                     ---- In Progress QCState
                            getdate(),                         -----modified
                            @createdBy,
                            'urn:lsid:ohsu.edu:Study.Data-6:5006.10003.19810204.0000.' + '' + @RunID + ''

            )

                             If @@Error <> 0
                                  GoTo Err_Proc



END


             ----- Proceed and fetch the next record

                Set @TempSearchKey = @SearchKey

Select Top 1 @SearchKey = rowid from onprc_ehr.TB_TestTemp
Where rowid > @TempSearchKey
Order by rowid


END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

  Insert into onprc_ehr.TB_TestTempMaster
     Select *  from onprc_ehr.TB_TestTemp

         If @@Error <> 0
	  			GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, program processed stopped
	RETURN 1


END

GO

/*
**
** 	Created by
**      R. Blasa   6-5-2024      A  Program Process that reviews all TB Test entries on a given date, and creates a
**                                               new TB Test Clinical Observation record based on
**                                               having the same monkey id, date, and to be assigned to a Data Admin for reviews.
**
**       R. Blasa                Modified program so that each Clinical Observation entries generated by the program is assigned
**                                only a single task id when the program executes daily.
**
**
*/

  ALTER Procedure onprc_ehr.p_Create_TB_Observationrecords



    AS



DECLARE
              @SearchKey              Int,
			  @TempsearchKey	      Int,
			  @TaskId		          varchar(4000),
		      @ObjectId               varchar(4000),
              @AnimalID               varchar(100),
              @date                   datetime,
              @createdby              smallint,
              @created                smalldatetime,
			  @performedby            varchar(200),
              @RunID                 varchar(4000)




BEGIN



    ---- Reset temp table

Truncate table onprc_ehr.TB_TestTemp


    If @@Error <> 0
	  GoTo Err_Proc


    --- Generate a list TB test monkeys                        )

     Insert into onprc_ehr.TB_TestTemp

select
    a.participantid,
    a.date,
    a.objectid,
    a.created,
    a.createdBy,
    a.performedby




from studydataset.c6d214_encounters  a
Where a.participantid not in (select b.participantid  from studydataset.c6d171_clinical_observations b
                              where a.participantid = b.participantid
                               And cast(b.date as date)  = dateadd(day,3,cast(a.date as date))
                               And b.category = 'TB TST Score (72 hr)'
                                And a.created >=  cast(getdate() as date)
                                 And a.type = 'Procedure' And a.qcstate = 18 And a.procedureid = 802   )

  And a.type = 'Procedure' And a.qcstate = 18 And a.procedureid = 802         -----'TB Test Intradermal'
  And a.created >=  cast(getdate() as date)
And a.participantid in ( select k.participantid from studydataset.c6d203_demographics k
    where k.calculated_status = 'alive')

order by a.participantid, a.date desc


    If @@Error <> 0
	 		 GoTo Err_Proc

        ---- When there are no records to process, exit immediately from the program.

    If (Select count(*) from onprc_ehr.TB_TestTemp) = 0
    BEGIN
    GOTO No_Records
    END


    ---- Reset temp variables

          Set @SearchKey = 0
          Set @TempSearchKey = 0
          Set @Date = NULL
          Set @created = NULL
          Set @createdby =NULL
          Set @performedby = NULL
          Set @TaskID = NULL
          Set @Animalid = Null
          Set @RunID   = Null



      ----- extract initial row id

        Select Top 1 @Searchkey = rowid  from onprc_ehr.TB_TestTemp
        Order by rowid


                    Set @TaskID = NEWID()         ----- Task Record Object ID

                    ----Create a single task for each daily process


                            Insert into EHR.Tasks
                        (
                            taskid,
                            description,
                            title,
                            qcstate,
                            formType,
                            category,
                            container,
                            assignedto,
                            created,
                            createdby,
                            modified,
                            modifiedby

                        )

                        Values  (

                            @TaskID,
                            'TB TST Scores ' + cast(@Date as varchar(50)) ,   	        ------ Title  consist of animal id and Clinical procedure date
                            'TB TST Scores',
                            20,                     	              --- Qc State (In Progress)
                            'TB TST Scores',              	      ------ FormType
                            'task',                 		      -----  category,
                            'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
                            1822,                               -------- Assigned To Data Admins
                            getdate(),                                ------- Create Date
                            1042, 				     -------- Created By IS
                            getdate(), 				     ------- Modified Date
                            1042				     ----- Modified by IS

                            )

                            If @@Error <> 0
                               GoTo Err_Proc



    While @TempSearchKey < @SearchKey
    BEGIN

                    -----Begin entry Tb observation process

       Select @Animalid =animalid, @date = date, @created =created, @createdby =createdby,@performedby= performedby from onprc_ehr.TB_TestTemp Where rowid = @Searchkey

    If not exists (select * from studydataset.c6d171_clinical_observations j Where j.participantid  = @AnimalID
                                             And cast(j.date as date) = dateadd(day,3,cast(@date as date)) And j.category = 'TB TST Score (72 hr)'   )
    BEGIN



               ----- Initialize data entries
                Set @RunID = NEWID()          ---- ObjectID
                Set @date = dateadd(day, 3,@date)  ----- Add three days from TB Test date



               --- Create a Clinical Observation Record

                Insert into studydataset.c6d171_clinical_observations
                        (
                          participantid,
                          date,
                          category,
                          area,
                          observation,
                          created,
                          createdby,
                          performedby,
                          objectid,
                          taskid,
                          qcstate,
                          modified,
                          modifiedby,
                          lsid

                           )
                      values (
                          @animalid,
                          @date,
                          'TB TST Score (72 hr)',
                         'Right Eyelid',
                         'Grade: Negative',
                          getdate(),                         ----- created
                          @createdby,
                          @performedby,
                           @RunID ,                                    ----- Objectid
                           @TaskID,
                            20 ,                                     ---- In Progress QCState
                            getdate(),                         -----modified
                            @createdBy,
                            'urn:lsid:ohsu.edu:Study.Data-6:5006.10003.19810204.0000.' + '' + @RunID + ''

            )

                             If @@Error <> 0
                                  GoTo Err_Proc



END


             ----- Proceed and fetch the next record

                Set @TempSearchKey = @SearchKey

Select Top 1 @SearchKey = rowid from onprc_ehr.TB_TestTemp
Where rowid > @TempSearchKey
Order by rowid


END ----   While @TempSearchKey


            ----- Create a master copy of the completed transaction

  Insert into onprc_ehr.TB_TestTempMaster
     Select *  from onprc_ehr.TB_TestTemp

         If @@Error <> 0
	  			GoTo Err_Proc



No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, program processed stopped
	RETURN 1


END

GO

/* 24.xxx SQL scripts */

--added to allow insert of calculated fields from eIACUC

--2024-12-13 In development need to use a drop if exists statement for these to run

ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [BaseProtocol] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [RevisionNumber] varchar(100) Null;
ALTER TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS ADD [NewestRecord] INT Null;

GO

CREATE PROCEDURE onprc_ehr.BaseProtocol
AS
BEGIN
    -- Create a Common Table Expression (CTE) named BaseProtocol
    WITH BaseProtocol AS
             (
                 SELECT
                     RowID,
                     Protocol_id,
                     -- Determine the BaseProtocol based on the length of the Protocol_id
                     CASE
                         WHEN LEN(Protocol_id) > 10 THEN SUBSTRING(Protocol_id, 6, 15)
                         ELSE Protocol_id
                         END AS BaseProtocol,
                     -- Determine the RevisionNumber based on the length of the Protocol_id
                     CASE
                         WHEN LEN(Protocol_id) > 10 THEN SUBSTRING(Protocol_id,1, 5)
                         ELSE 'Original'
                         END AS RevisionNumber,
                     approval_date,
                     Three_Year_Expiration,
                     last_modified,
                     Protocol_State
                 FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
             )

    -- Update the onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS table with BaseProtocol and RevisionNumber from the CTE
    UPDATE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    SET BaseProtocol = BaseProtocol.BaseProtocol,
        RevisionNumber = BaseProtocol.RevisionNumber
    FROM BaseProtocol
    WHERE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS.RowID = BaseProtocol.RowID;
END
GO

GO
/****** Object:  StoredProcedure [onprc_ehr].[ExpiredProtocolUpdate]    Script Date: 12/20/2024 9:09:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [onprc_ehr].[ExpiredProtocolUpdate]
    AS
BEGIN

WITH ApprovedProtocols AS (
    SELECT
        BaseProtocol,
        MAX(Approval_Date) AS maxApprovalDate
    FROM
        onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    WHERE
        Protocol_State IN ('approved','expired', 'terminated')
    GROUP BY
        BaseProtocol
),


     DistinctProtocols AS (
         SELECT DISTINCT
             p.rowID,
             p.BaseProtocol,
             p.RevisionNumber,
             p.Protocol_State,
             p.Approval_Date,
             p.Last_Modified,
             p.Three_Year_Expiration
         FROM
             onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
                 INNER JOIN ApprovedProtocols ap ON p.BaseProtocol = ap.BaseProtocol
                                AND p.Approval_Date = ap.maxApprovalDate),
     ExpiredProtocol AS (
         Select
             d.*,
             p.protocol,
             p.enddate
         from DistinctProtocols d inner join ehr.protocol p on d.BaseProtocol = p.external_ID
            where d.Protocol_State != 'Approved' and p.enddate is Null)

Update p
    Set p.enddate = getDate()
    from ehr.protocol p inner join expiredProtocol e on p.external_id = e.BaseProtocol
END

GO

CREATE TABLE onprc_ehr.procedure_default_blood (
 rowid int identity(1,1),
  procedureid  int,
  sampletype varchar(300) Null,
  additionalServices varchar(1000) Null,
  reason varchar(300) Null,
  instructions varchar(2000) Null,
  chargetype varchar(400) Null


  CONSTRAINT PK_procedure_default_blood PRIMARY KEY (rowid)
)

GO

CREATE TABLE [onprc_ehr].[Rpt_AnimalID_Weights](
    searchid      int IDENTITY(100,1) NOT NULL,
    animalID      varchar(100) NULL,
    date         smalldatetime NULL,
    weight       decimal(12,5) NULL,
    taskId       ENTITYID NULL,
    created      smalldatetime NULL,
    createdby    smallint NULL,
    modified     smalldatetime NULL,
    modifiedby   smallint NULL

    ) ON [PRIMARY]

    GO


CREATE TABLE [onprc_ehr].[Rpt_AnimalID_WeightsMaster](
    searchid      int IDENTITY(100,1) NOT NULL,
    rowid         int,
    animalID      varchar(100) NULL,
    date         smalldatetime NULL,
    weight       decimal(12,5) NULL,
    taskId       ENTITYID NULL,
    created      smalldatetime NULL,
    createdby    smallint NULL,
    modified     smalldatetime NULL,
    modifiedby   smallint NULL,
    actual_created  smalldatetime NULL,
    remark       varchar(1000) NULL

    ) ON [PRIMARY]

    GO


/*
**
** 	Created by 		Date
**
**      Blasa  		       1-29-2025      Extract the Pathology Tissue Weights from Pathology Tissue records.
**
**                              T-00010 BODY AS A WHOLE  Tissue_Samples data set
**
**
**
**
**
**
**
*/


CREATE Procedure onprc_ehr.sp_PathologyTissueWeightsProcess
    @StartDate    SmallDateTime,
    @EndDate      SmallDateTime




    AS



DECLARE       @ReturnValue  	   Int,
			  @SearchKey           Int,
			  @TempsearchKey	   Int,
              @AnimalID            varchar(100),
              @Date                smalldatetime,
			  @RunID               varchar(4000)


Begin


				----- Reset Temp Table

				Set @Returnvalue = 0


			   ----- Reset Temp tables
			  Delete onprc_ehr.Rpt_AnimalID_Weights


				        If @@Error <> 0
		    			  GoTo Err_Proc



			Insert into onprc_ehr.Rpt_AnimalID_Weights
select
    e.participantid,
    e.date,
    e.weight,
    e.taskid,
    e.created,
    e.createdby,
    e.modified,
    e.modifiedby


from studydataset.c6d174_tissue_samples e
where e.tissue = 'T-00010'
  And (e.date >= @StartDate And e.date < Dateadd(day,1,@EndDate)  )

  and e.qcstate = 18
  and e.weight is not null
order by date desc




    If @@Error <> 0
    GoTo Err_Proc


Set @TempsearchKey = 0
Set @SearchKey = 0

Select Top 1 @Searchkey = Searchid from onprc_ehr.Rpt_AnimalID_Weights
Order by SearchID





    While @TempSearchKey < @SearchKey
    Begin

                  ---- Reset temp variables
                  Set @AnimalID = null
                  Set @Date = null
                  Set @RunID = null

                               ----Extract primary weights data from Pathology records

                 Select @Animalid = animalid, @Date = date from onprc_ehr.Rpt_AnimalID_Weights  where searchid = @Searchkey

                                                                               ---- Create Weights entries

                If not exists(select * from studydataset.c6d175_weight
                Where participantid = @AnimalID And date = @Date )


                Begin
						----- Set record object id
                                              Set @RunID = NEWID()

					        Insert into studydataset.c6d175_weight
                                                       (participantid,
                                                        date,
                                                        weight,
                                                        qcstate,
                                                        created,
                                                        createdby,
                                                        modified,
                                                        modifiedby,
                                                        taskid,
                                                        objectid,
                                                        remark,
                                                        lsid
                                                             )

                            Select @AnimalID,
                                   @Date,
                                   Rpt.weight/1000,    ----- convert weight from grams to Kilograms
                                   18,                ------ default QC State
                                   Rpt.created,
                                   Rpt.createdby,
                                   Rpt.modified,
                                   Rpt.modifiedby,
                                   Rpt.taskid,
                                   @RunID,           ------- record object id
                                   'Weight added from Path Tissue records',
                                   ' urn:lsid:ohsu.edu:Study.Data-6:1045.' + @AnimalID + '.' + format(cast(@date as date), 'yyyyMMdd') + '.0000.' + @RunID + ''



                                    from  onprc_ehr.Rpt_AnimalID_Weights Rpt
                                    where searchid = @Searchkey

                                        If @@Error <> 0
	    				                      GoTo Err_Proc



                End  ----




			            Set @TempSearchkey = @SearchKey


            Select Top 1 @Searchkey = Searchid from onprc_ehr.Rpt_AnimalID_Weights
            Where Searchid > @TempSearchkey
            Order by Searchid




    End -----(While)

                    ------- Create a Master log of entries

                        Insert into onprc_ehr.Rpt_AnimalID_WeightsMaster
                        Select j.*,
                               getdate(),    ---- record created date
                               'Pathology Tissue Weight entry'

                        from onprc_ehr.Rpt_AnimalID_Weights j


    RETURN 0

Err_Proc:

	 Return 1


END

GO

-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2025-03-04
-- Description:	Db tables creation for Prima cassette project. Created all the Prima tables in Prime onprc_ehr schema folder.
-- Refer to tkt #11937
-- =======================================================================================================================================

--Drop if exists. We are using these 4 tables for the Cassette Project
EXEC core.fn_dropifexists 'Prima_Animals','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE'; -- Drop this table and create again
EXEC core.fn_dropifexists 'Prima_TissueCollections','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE'; -- Drop this table and create again

--Drop these tables permanently. We are not using these tables in onprc_ehr.
EXEC core.fn_dropifexists 'Prima_VeterinaryResearchCase','onprc_ehr','TABLE'; --This table doesn't exist anymore in Prima DB
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';

GO

--Create tables
--1. Animals table
/****** Object:  Table [onprc_ehr].[Prima_Animals]  ******/
CREATE TABLE [onprc_ehr].[Prima_Animals](
    [Id] [int] NOT NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [BreedId] [int] NULL,
    [DateOfBirth] [datetime] NULL,
    [FecesId] [int] NULL,
    [Gender] [tinyint] NOT NULL,
    [GeneTarget] [nvarchar](127) NULL,
    [GeneticLine] [nvarchar](127) NULL,
    [Genotype] [nvarchar](127) NULL,
    [Identifier] [nvarchar](127) NULL,
    [MannerOfDeathId] [int] NULL,
    [RoomNumber] [nvarchar](9) NULL,
    [SpeciesId] [int] NOT NULL,
    [StomachContentsId] [int] NULL,
    [StrainId] [int] NULL,
    [DateOfDeath] [datetime] NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OwnerId] [int] NULL,
    [Perfuse] [bit] NOT NULL,
    [SampleType] [tinyint] NOT NULL
    )
;

--2. TissueCollections table
/****** Object:  Table [onprc_ehr].[Prima_TissueCollections]  ******/
CREATE TABLE [onprc_ehr].[Prima_TissueCollections](
    [Id] [int] NOT NULL,
    [Constant] [tinyint] NULL,
    [IsWholeAnimal] [bit] NOT NULL,
    [SpeciesId] [int] NOT NULL,
    [SpecimenType] [int] NOT NULL,
    [CreatedByUserId] [int] NOT NULL,
    [Deleted] [datetimeoffset](7) NULL,
    [DeletedByUserId] [int] NULL,
    [NextVersionId] [int] NULL,
    [PreviousVersionId] [int] NULL,
    [Title] [nvarchar](127) NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [LastModified] [timestamp] NOT NULL,
    [Abbreviation] [nvarchar](127) NULL
    )
;

--3. CaseBase table
/****** Object:  Table [onprc_ehr].[Prima_CaseBase]  ******/
CREATE TABLE [onprc_ehr].[Prima_CaseBase](
    [Id] [int] NOT NULL,
    [DifferentialDiagnosisId] [int] NULL,
    [PathologistId] [int] NULL,
    [PriorityLevelId] [int] NOT NULL,
    [ResidentPathologistId] [int] NULL,
    [SerialNumber] [int] NOT NULL,
    [SurgeryDate] [datetime] NULL,
    [SurgicalWheelId] [int] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [ResearcherId] [int] NULL,
    [StudyId] [int] NULL,
    [Discriminator] [nvarchar](128) NULL,
    [StudyPhaseId] [int] NULL,
    [CohortId] [int] NULL,
    [SavedIdentifier] [nvarchar](max) NULL,
    [Status] [tinyint] NOT NULL,
    [AlternateIdentifier] [nvarchar](24) NULL,
    [SurgeryLocationId] [int] NULL,
    [ResearchPatientId] [int] NULL,
    [AnimalId] [int] NULL,
    [ClinicalPatientId] [int] NULL,
    [SurgeryAge] [nvarchar](31) NULL
    )
;

--4. CassetteBases table
/****** Object:  Table [onprc_ehr].[Prima_CassetteBases]  ******/
CREATE TABLE [onprc_ehr].[Prima_CassetteBases](
    [Id] [bigint] NOT NULL,
    [CassetteColorId] [int] NOT NULL,
    [EmbeddingInstructionId] [int] NOT NULL,
    [HasTissue] [bit] NOT NULL,
    [ProtocolCassetteId] [int] NULL,
    [SpecimenBaseId] [bigint] NOT NULL,
    [TissueCollectionId] [int] NULL,
    [TissueProcessorProgramId] [int] NULL,
    [TissueQuantity] [smallint] NOT NULL,
    [CaseBaseId] [int] NOT NULL,
    [PriorityLevelId] [int] NOT NULL,
    [QcStatus] [tinyint] NOT NULL,
    [SurgicalSerialPart] [smallint] NOT NULL,
    [Created] [datetimeoffset](7) NOT NULL,
    [OrderedStatus] [tinyint] NOT NULL,
    [SavedIdentifier] [nvarchar](24) NULL,
    [BarcodeContent] [nvarchar](72) NULL,
    [AlternateIdentifier] [nvarchar](63) NULL,
    [PrintStatus] [tinyint] NOT NULL,
    [ItemStatus] [smallint] NOT NULL,
    [Hazard] [tinyint] NOT NULL,
    [CurrentContainerId] [int] NULL
    )
;

GO

CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues(
    [Searchkey] 	[int] IDENTITY(1,1) NOT NULL,
    [animalID]      varchar(100) NULL,
    [date]          smalldatetime NULL


 ) ON [PRIMARY]
    GO

CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues_Master(
    [rowid] 		[int] IDENTITY(1,1) NOT NULL,
    [SearchID]          int NULL,
    [animalID]      	varchar(100) NULL,
    [date]          	smalldatetime NULL,
    [actual_Created]  	smalldatetime NUll,
    [remarks]       	varchar(500)


 ) ON [PRIMARY]
    GO



/*
**
** 	Created by 		Date
**
**      Blasa  		        4/4/2025  Process to attached Tissues Distribution records to Patholody Tissue records
**
**

**
**
**
**
**

**
**
**
*/


CREATE Procedure [onprc_ehr].[sp_RptNecropsyTissueDistributionUpdates]
			      @StartDate    SmallDateTime,
			      @EndDate      SmallDateTime




AS



DECLARE @ReturnValue  		Int,
			  		 @SearchKey             Int,
			  		 @TempsearchKey		    Int,
			  		 @TaskId		         varchar(4000),
		          	 @ObjectId              Varchar(4000),
                     @AnimalID              varchar(100),
                     @Date                  smalldatetime,
                     @Created               smalldatetime,
                     @Createdby             smallint,
                     @modified              smalldatetime,
                     @modifiedby            smallint ,
                     @RunID                 varchar(4000)

Begin


				----- Reset Temp Table

				      Set @Returnvalue = 0



			    Delete onprc_ehr.Rpt_AnimalIDTissues


				          	 If @@Error <> 0
		    					 GoTo Err_Proc


				----Create the set of records to process

	Insert into onprc_ehr.Rpt_AnimalIDTissues
         select distinct
          e.participantid,
          e.date


from studydataset.c6d265_tissuedistributions e

Where (e.date >= @StartDate And e.date < Dateadd(day,1,@EndDate)  )
  And e.qcstate = 18
order by e.participantid, e.date



    If @@Error <> 0
		GoTo Err_Proc



Set @TempsearchKey = 0
Set @SearchKey = 0
Set @TaskID = null

Select Top 1 @Searchkey = Searchkey from onprc_ehr.Rpt_AnimalIDTissues
Order by Searchkey


    While @TempSearchKey < @SearchKey
Begin

					------ Create a task record

                                      Set @TaskID = NEWID()


      					Insert into EHR.Tasks
                      				  (
                           			  taskid,
                          			  description,
                            		  title,
                           			  qcstate,
                            		  formType,
                           			  category,
                            		  container,
                                      assignedto,
                                      created,
                                      createdby,
                                      modified,
                                      modifiedby

                                        )

                                Values  (

                                      @TaskID,
                                      'Path Tissues ' + cast(@Date as varchar(50)) ,   	        ------ Title
                           			 'PathologyTissues',
                           			  18,                     	                     --- Qc State (In Progress)
                            		  'PathologyTissues',              	             ------ FormType
                            		   'task',                 		      -----  category,
                           			 'CD17027B-C55F-102F-9907-5107380A54BE',    ---- EHR Container
                           			  1693,                                   -------- Assigned To DCM Pathology
                           			  getdate(),                                ------- Created Date
                            			  1042, 				     -------- Created By IS
                           			  getdate(), 				     ------- Modified Date
                            			  1042				           ----- Modified by IS

                          			   )

                           			 If @@Error <> 0
                            				   GoTo Err_Proc



Select  @AnimalID = rpt.AnimalID, @Date= rpt.date, @Created=TDS.created, @Createdby= TDS.createdby, @modified = TDS.modified
from studydataset.c6d265_tissuedistributions TDS, onprc_ehr.Rpt_AnimalIDTissues Rpt
Where TDS.participantid = Rpt.AnimalID
  And TDS.date = RPT.date And Rpt.searchkey = @Searchkey


If exists (Select * from studydataset.c6d265_tissuedistributions Where participantid = @AnimalID And date = @date)
Begin
         Update TDS
         set  TDS.taskid = @TaskID

    from studydataset.c6d265_tissuedistributions TDS
Where TDS.participantid = @AnimalID
  And TDS.date = @Date


    If @@Error <> 0
    GoTo Err_Proc

End            --


		  Set @TempSearchkey = @SearchKey


Select Top 1 @Searchkey = Searchkey from onprc_ehr.Rpt_AnimalIDTissues
Where Searchkey > @TempSearchkey
Order by Searchkey


End -----(While)

                                 ------- Create a audit records

Insert into onprc_ehr.Rpt_AnimalidTissues_Master
Select *,
       getdate(),
       'Tissue Distribution entries'
from onprc_ehr.Rpt_AnimalIDTissues


 RETURN 0

Err_Proc:

	 Return 1


END

GO

CREATE TABLE onprc_ehr.snomed_counter
(
    subset		nvarchar(255) NOT NULL,
    count		integer NOT NULL,
    prefix		nvarchar(10) NOT NULL,
    container   entityid,
    createdby   userid,
    created     DATETIME,
    modifiedby  userid,
    modified    DATETIME,

    CONSTRAINT pk_snomed_counter PRIMARY KEY (subset),
    CONSTRAINT fk_onprc_snomed_counter_container FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
)

CREATE TABLE onprc_ehr.CenterProjectsTemp(
    [searchid] [int] IDENTITY(100,1) NOT NULL,
    [project] [smallint] NULL,
    [protocol] [smallint] NULL,
    [account] [varchar](1000) NULL,
    [title] [varchar](2000) NULL,
    [research] [smallint] NULL,
    [createdby] [smallint] NULL,
    [created] [datetime] NULL,
    [modified] [datetime] NULL,
    [modifiedby] [smallint] NULL,
    [startdate] [datetime] NULL,
    [enddate] [datetime] NULL,
    [displayname] [varchar](1000) NULL,
    [investigatorid] [smallint] NULL,
    [use_category] [varchar](500) NULL,
    [projecttype] [varchar](500) NULL,
    [objectid] [varchar](max) NULL,
    [date_posted] [datetime] NULL

 ) ON [PRIMARY]
    GO


/*
**
** 	Created by
**      Blasa  		5/31/2025          Process to create Center Projects historical records.  First create a complete set
**                                     of currently active records, and after the intitial date, just create a record of entries that
**                                     was recently modified.
**

**
**
**
**
*/

CREATE Procedure onprc_ehr.p_CenterProjectsHistoricalProcess
             @InitialDate smalldatetime


    AS

BEGIN

   ----- Create a fulle record once only

IF (cast(getdate() as date) = @InitialDate  )
BEGIN
   Insert into  onprc_ehr.CenterProjectsTemp
     (
    project,
    protocol,
    account,
    title,
    research,
    createdby,
    created,
    modified,
    modifiedby,
    startdate,
    enddate,
    displayname,
    investigatorid,
    use_category,
    projecttype,
    objectid,
    date_posted
)

Select
    project,
    protocol,
    account,
    title,
    research,
    createdby,
    created,
    modified,
    modifiedby,
    startdate,
    enddate,
    name,                 -----displayname
    investigatorid,
    use_category,
    projecttype,
    objectid,
    getdate()

    From ehr.project where (enddate is null or enddate >= getdate())
    order by modified

   END

    If @@Error <> 0
    GoTo Err_Proc


   ------ Create modiified records
if exists(Select * from ehr.project where (enddate is null or enddate >= getdate())
                   And modified >= cast(getdate() as date))
BEGIN

   Insert into  onprc_ehr.CenterProjectsTemp
     (
    project,
	protocol,
	account,
	title,
	research,
	createdby,
	created,
	modified,
	modifiedby,
	startdate,
	enddate,
	displayname,
	investigatorid,
	use_category,
	projecttype,
	objectid,
	date_posted
        )

Select
    project,
    protocol,
    account,
    title,
    research,
    createdby,
    created,
    modified,
    modifiedby,
    startdate,
    enddate,
    name,                 -----displayname
    investigatorid,
    use_category,
    projecttype,
    objectid,
    getdate()

From ehr.project where (enddate is null or enddate >= getdate())
                   And modified >= cast(getdate() as date)
order by modified



    If @@Error <> 0
	  GoTo Err_Proc

END ----if


 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO

ALTER TABLE onprc_ehr.CenterProjectsTemp ALTER COLUMN protocol VARCHAR(400);
GO

CREATE TABLE onprc_ehr.pairing_observation_types (
                 rowid [int] IDENTITY(100,1) NOT NULL,
                 value nvarchar(200),
                 category nvarchar(200),
                 editorconfig NVARCHAR(MAX),
                 schemaname nvarchar(200),
                 queryname nvarchar(200),
                 valuecolumn nvarchar(200),
                 Created datetime,
                 CreatedBy USERID,
                 Modified datetime,
                 ModifiedBy USERID,
                 Container	entityId NOT NULL,

                 CONSTRAINT PK_ONPRC_EHR_PAIRING_OBSERVATION_TYPES PRIMARY KEY (rowid),

);
GO

/*
**
** 	Created by
**      Blasa  		10/8/2025          Process to update birth record;s geogrphic origin data.  The "Genetic Ancestry"
**                                      geographic_origin information must override the birth's geographic origin values.
**

**
**
**
**
*/

CREATE Procedure onprc_ehr.p_BirthGeographicOriginUpdates

    as


BEGIN

   ----- Process data

  IF exists (select *  From studydataset.c6d202_birth bir, studydataset.c6d512_geneticancestry b where bir.participantid = b.participantid
    And b.enddate is null
    and bir.qcstate = 18
    and b.qcstate = 18
    And bir.geographic_origin <> b.result
    And b.result is not null
              )



    BEGIN

   ---- Update birth geographic origin

   Update bir
   set bir.geographic_origin = b.result,
       bir.modified = getdate(),
       bir.modifiedby = b.modifiedby    ---- ancestry staff

    From studydataset.c6d202_birth bir, studydataset.c6d512_geneticancestry b
    where bir.participantid = b.participantid
    And b.enddate is null
    And bir.qcstate = 18
    And b.qcstate = 18
    And bir.geographic_origin <> b.result
    And b.result is not null


    If @@Error <> 0
         GoTo Err_Proc

END  ---- if





RETURN 0


    Err_Proc:
                    -------Error Generated, process stopped
	RETURN 1


END

GO