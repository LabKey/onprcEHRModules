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

CREATE SCHEMA onprc_ehr;

CREATE TABLE onprc_ehr.etl_runs
(
    RowId SERIAL,
    date TIMESTAMP,
    Container ENTITYID NOT NULL,
    queryname varchar(200),
    rowversion varchar(200),

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);

CREATE TABLE onprc_ehr.investigators (
    rowId SERIAL NOT NULL,
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
    dateCreated TIMESTAMP,
    dateDisabled TIMESTAMP,
    division varchar(100),
    financialAnalyst int,
    createdby userid,
    created TIMESTAMP,
    modifiedby userid,
    modified TIMESTAMP,
    objectid ENTITYID,
    assignedVet int,
    userid int,
    employeeid varchar(100),
    Department varchar(250) NULL,

    CONSTRAINT pk_investigators PRIMARY KEY (rowid)
);

CREATE INDEX investigators_rowid_lastname ON onprc_ehr.investigators (rowid, lastname);

CREATE TABLE onprc_ehr.serology_test_schedule (
  rowid SERIAL,
  code varchar(100),
  flag varchar(100),
  interval int,
  species VARCHAR(100),

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

CREATE TABLE onprc_ehr.customers (
  rowId SERIAL NOT NULL,
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
  dateCreated TIMESTAMP,
  dateDisabled TIMESTAMP,
  investigatorId int,
  objectid entityid,
  container entityid,
  createdby userid,
  created TIMESTAMP,
  modifiedby userid,
  modified TIMESTAMP,

  CONSTRAINT pk_customers PRIMARY KEY (rowid)
);

-- TODO: Assuming this can be deleted, no longer needed for PostgreSQL
-- INSERT INTO core.SqlScripts (Created, Createdby, Modified, Modifiedby, FileName, ModuleName)
-- SELECT Created, Createdby, Modified, Modifiedby, FileName, 'ONPRC_Billing' as ModuleName
-- FROM core.SqlScripts
-- WHERE FileName LIKE 'onprc_billing-%' AND ModuleName = 'ONPRC_EHR';

CREATE TABLE onprc_ehr.vet_assignment (
  rowid SERIAL,
  userid int,
  area varchar(100),
  protocol varchar(100),
  container ENTITYID NOT NULL,
  created TIMESTAMP,
  createdby int,
  modified TIMESTAMP,
  modifiedby int,
  room varchar(100),
  priority BOOLEAN,
  project INT,

  CONSTRAINT PK_vet_assignment PRIMARY KEY (rowid)
);

CREATE TABLE onprc_ehr.housing_transfer_requests (
  Id varchar(100),
  date TIMESTAMP,
  room varchar(200),
  cage varchar(100),
  reason varchar(100),
  remark varchar(4000),
  qcstate int,
  requestid entityid,
  objectid entityid NOT NULL,
  container entityid,
  created TIMESTAMP,
  createdby int,
  modified TIMESTAMP,
  modifiedby int,
  divider integer,
  formSort integer,

  CONSTRAINT PK_housing_transfer_requests PRIMARY KEY (objectid)
);

UPDATE ehr.tasks SET formtype = 'Bulk Clinical Entry' WHERE formtype = 'Clinical Remarks';

CREATE TABLE onprc_ehr.birth_condition (
    rowid SERIAL,
    value varchar(200),
    alive BOOLEAN,
    description varchar(4000),
    container entityid,
    createdby int,
    created TIMESTAMP,
    modifiedby int,
    modified TIMESTAMP,

    CONSTRAINT PK_birth_condition PRIMARY KEY (rowid)
);

UPDATE ehr.qcStateMetadata SET draftData = TRUE WHERE QCStateLabel = 'Request: Pending';

CREATE TABLE onprc_ehr.encounter_summaries_remarks (
  id varchar(100),
  date TIMESTAMP,
  parentid entityid,
  schemaName varchar(100),
  queryName varchar(100),
  remark text,
  objectid varchar(60) NOT NULL,
  container entityid NOT NULL,
  createdby userid,
  created TIMESTAMP,
  modifiedby userid,
  modified TIMESTAMP,
  taskid  entityid,
  category varchar(100),
  formsort integer,

  CONSTRAINT pk_encounter_summaries_remarks PRIMARY KEY (objectid)
);

CREATE TABLE onprc_ehr.NHP_Training(
   RowId SERIAL NOT NULL,
   Id                  varchar(100),
   date                TIMESTAMP NULL,
   training_Ending_Date TIMESTAMP NULL,
   training_type        varchar(255) NULL,
   reason              varchar(255) NULL,
   qcstate              INTEGER    NULL,
   taskid 	             varchar(4000) NULL,
   remark              varchar(4000) NULL,
   objectid 	          ENTITYID NOT NULL,
   formSort             SMALLINT  NULL,
   performedby   	      varchar(4000) NULL,
   createdby            int NULL,
   created              TIMESTAMP NULL,
   modifiedby           int NULL,
   modified             TIMESTAMP  NULL,
   Container 	          ENTITYID,
   training_results     varchar(255) NULL,

   CONSTRAINT PK_NHPTrainingObject PRIMARY KEY (objectid)
);

CREATE TABLE onprc_ehr.AvailableBloodVolume(
    datecreated TIMESTAMP NULL,
    id varchar(32) NOT NULL,
    gender varchar(4000) NULL,
    species varchar(4000) NULL,
    yoa double precision NULL,
    mostrecentweightdate TIMESTAMP NULL,
    weight double precision NULL,
    calcmethod varchar(32) NULL,
    BCS double precision NULL,
    BCSage int NULL,
    previousdraws double precision NULL,
    ABV double precision NULL,
    dsrowid bigint NOT NULL,

    CONSTRAINT PK_AvailableBloodVolume PRIMARY KEY (Id)
);

CREATE TABLE onprc_ehr.Reference_StaffNames(
   RowId                    SERIAL NOT NULL,
   username                 varchar(100),
   LastName                 varchar(100) NULL,
   FirstName                varchar(100) NULL,
   displayname               varchar(100) NULL,
   Type                     varchar(100) NULL,
   role                     varchar(100) NULL,
   remark                   varchar(200) NULL,
   SortOrder                smallint  NULL,
   StartDate                TIMESTAMP NULL,
   DisableDate              TIMESTAMP NULL,

   CONSTRAINT pk_reference PRIMARY KEY (username)
);

CREATE TABLE onprc_ehr.Frequency_DayofWeek(
  RowId                    SERIAL NOT NULL,
  FreqKey                  SMALLINT  NULL,
  value                    SMALLINT  NULL,
  Meaning                  varchar(400) NULL,
  calenderType             varchar(100) NULL,
  Sort_order               SMALLINT NULL,
  DisableDate              TIMESTAMP NULL,

  CONSTRAINT pk_FreqWeek PRIMARY KEY (RowId)
);

CREATE TABLE onprc_ehr.usersActiveNames(
    Email varchar(64) NULL,
    _ts TIMESTAMP NOT NULL,
    EntityId ENTITYID NULL,
    CreatedBy USERID NULL,
    Created TIMESTAMP NULL,
    ModifiedBy USERID NULL,
    Modified TIMESTAMP NULL,
    Owner USERID NULL,
    UserId USERID NOT NULL,
    DisplayName varchar(64) NOT NULL,
    FirstName varchar(64) NULL,
    LastName varchar(64) NULL,
    Phone varchar(64) NULL,
    Mobile varchar(64) NULL,
    Pager varchar(64) NULL,
    IM varchar(64) NULL,
    Description varchar(255) NULL,
    LastLogin TIMESTAMP NULL,
    Active BOOLEAN NOT NULL
);

CREATE TABLE onprc_ehr.eIACUC_PRIME_VIEW_ANIMAL_GROUPS(
	rowid SERIAL NOT NULL,
	Parent_Protocol varchar(255) NOT NULL,
	Group_ID varchar(255) NULL,
	Group_Name varchar(255) NULL,
	Species varchar(255) NULL,
	SPF_Status varchar(255) NULL,
	Weight_Start varchar(255) NULL,
	Weight_End varchar(255) NULL,
	Age_Start varchar(255) NULL,
	Age_End varchar(255) NULL,
	Gender varchar(255) NULL,
	Number_of_Animals_Max int NULL,
	Breeding_Colony int NULL,
	Non_Standard_Housing_Types text NULL,
	Non_Standard_Housing_Description text NULL,
	Non_Standard_Housing_Frequency_and_Duration text NULL,
	Non_Standard_Housing_Monitoring text NULL,
	createdby int NULL,
	created TIMESTAMP NULL,
	modifiedby int NULL,
	modified TIMESTAMP NULL,
	Restraint text NULL,
	Nutritional_Manipulation_Description text NULL,
	Nutritional_Manipulation_Adverse_Consequences text NULL,
	Nutritional_Manipulation_Health_Assessment text NULL,
	Non_Pharmaceutical_Grade_Drug_Use text NULL,
	Food_Withheld int NULL,
	Water_Withheld int NULL,
	Food_Water_Withheld_Description text NULL,
	Food_Water_Withheld_Justification text NULL,
	Food_Water_Withheld_Adverse_Consequences text NULL,
	Death_As_Endpoint_Number_of_Animals text NULL,
	Death_As_Endpoint_Justification text NULL
);

CREATE TABLE onprc_ehr.eIACUC_PRIME_VIEW_IBC_NUMBERS(
	rowid SERIAL NOT NULL,
	Animal_Group varchar(255) NOT NULL,
	IBC_Registration_Number varchar(255) NULL,
	createdby int NULL,
	created TIMESTAMP NULL,
	modifiedby int NULL,
	modified TIMESTAMP NULL
);

CREATE TABLE onprc_ehr.eIACUC_PRIME_VIEW_NON_SURGICAL_PROCS(
	rowid SERIAL NOT NULL,
	Animal_Group varchar(255) NOT NULL,
	NS_Procedure_Name varchar(255) NULL,
	Standard_Procedure int NULL,
	Iterations int NULL,
	Deviation int NULL,
	Deviation_Description varchar(255) NULL,
	Recovery_Days int NULL,
	createdby int NULL,
	created TIMESTAMP NULL,
	modifiedby int NULL,
	modified TIMESTAMP NULL
);

CREATE TABLE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS(
	rowid SERIAL NOT NULL,
	Protocol_ID varchar(255) NOT NULL,
	Template_OID varchar(32) NULL,
	Protocol_OID varchar(255) NULL,
	Protocol_Title varchar(255) NULL,
	PI_ID varchar(255) NULL,
	PI_First_Name varchar(255) NULL,
	PI_Last_Name varchar(255) NULL,
	PI_Email varchar(255) NULL,
	PI_Phone varchar(255) NULL,
	USDA_Level varchar(255) NULL,
	Approval_Date TIMESTAMP NULL,
	Annual_Update_Due TIMESTAMP NULL,
	Three_year_Expiration TIMESTAMP NULL,
	Last_Modified TIMESTAMP NULL,
	createdby int NULL,
	created TIMESTAMP NULL,
	modifiedby int NULL,
	modified TIMESTAMP NULL,
	PROTOCOL_State varchar(250) NULL,
	PPQ_Numbers varchar(255) NULL,
	Description varchar(255) NULL,
	BaseProtocol varchar(100) NULL,
	RevisionNumber varchar(100) NULL,
	NewestRecord INT NULL
);

CREATE TABLE onprc_ehr.eIACUC_PRIME_VIEW_SURGICAL_PROCS(
	rowid SERIAL NOT NULL,
	OID int NOT NULL,
	Animal_Group varchar(255) NOT NULL,
	Standard_Procedure int NULL,
	Iterations int NULL,
	Deviation int NULL,
	Deviation_Description varchar(255) NULL,
	Recovery_Days int NULL,
	Surgery_Name varchar(255) NULL
);

CREATE TABLE onprc_ehr.PotentialSire_source(
    RowId SERIAL NOT NULL,
	participantId varchar(32) NULL,
	Date TIMESTAMP NULL,
    Species varchar(100) NULL,
    room varchar(100) NULL,
    cage varchar(100) NULL,
    SireAgeAtTime integer NULL,
    PotentialSire varchar(100) NULL,
    SireBirth TIMESTAMP NULL,
    Siregender varchar(100) NULL,
    Sirespecies varchar(100) NULL,
    SireDeath TIMESTAMP NULL,
	created TIMESTAMP NULL,
	createdBy int NULL,
	modified TIMESTAMP NULL,
	modifiedBy int NULL,
	container ENTITYID,

	CONSTRAINT pk_potentialSire PRIMARY KEY (rowID)
);

CREATE TABLE onprc_ehr.PotentialDam_source(
    RowId SERIAL NOT NULL,
    participantId varchar(32) NULL,
    Date TIMESTAMP NULL,
    Species varchar(100) NULL,
    room varchar(100) NULL,
    cage varchar(100) NULL,
    DamAgeAtTime integer NULL,
    PotentialDam varchar(100) NULL,
    DamBirth TIMESTAMP NULL,
    Damgender varchar(100) NULL,
    DamSpecies varchar(100) NULL,
    DamDeath TIMESTAMP NULL,
    created TIMESTAMP NULL,
    createdBy int NULL,
    modified TIMESTAMP NULL,
    modifiedBy int NULL,
    container ENTITYID,

    CONSTRAINT pk_potentialDam PRIMARY KEY (rowID)
);

CREATE TABLE onprc_ehr.PotentialParents_source(
    RowId  SERIAL NOT NULL,
    participantId varchar(32) NULL,
    BirthDate TIMESTAMP NULL,
    Species varchar(100) NULL,
    BirthRoom varchar(100) NULL,
    Birthcage varchar(100) NULL,
    ParentAgeAtTime integer NULL,
    PotentialParent varchar(100) NULL,
    "[PotentialParentType" varchar(100) NULL,  -- TODO: Yes, we need to get rid of that bracket, but this is how it is in the SQL Server script
    ParentBirth TIMESTAMP NULL,
    Parentgender varchar(100) NULL,
    ParentSpecies varchar(100) NULL,
    ParentDeath TIMESTAMP NULL,
    created TIMESTAMP NULL,
    createdBy int NULL,
    modified TIMESTAMP NULL,
    modifiedBy int NULL,
    container ENTITYID,

    CONSTRAINT pk_potentialParent PRIMARY KEY (rowID)
);

CREATE OR REPLACE FUNCTION onprc_ehr.PotentialSire_Insert() RETURNS void AS $$
BEGIN
    TRUNCATE TABLE onprc_ehr.PotentialSire_source;
    INSERT INTO onprc_ehr.PotentialSire_source
    (participantId, Date, Species, room, cage, SireAgeAtTime, PotentialSire, sireBirth, siregender, sireSpecies, SireDeath, created, createdBy, modified, modifiedBy, container)
    SELECT
        b.participantid,
        b.date,
        b.species,
        b.room,
        b.cage,
        (b.date::date - d.birth::date) / 365,
        h.participantID,
        d.birth,
        d.gender,
        d.species,
        d.death,
        now(),
        1011,
        now(),
        1011,
        'CD17027B-C55F-102F-9907-5107380A54BE'::entityid
    FROM studyDataset.c6d202_birth b
             JOIN studyDataset.c6d194_housing h ON
        (b.participantId <> h.participantId AND
         (h.date <= b.date AND h.enddate >= b.date) AND
         h.room = b.room AND (h.cage = b.cage OR (h.cage IS NULL AND b.cage IS NULL))
            OR h.participantid = b.dam
            )
             JOIN studyDataset.c6d203_demographics d ON d.participantid = h.participantid
             JOIN studyDataset.c6d203_demographics d1 ON d1.participantID = b.participantid
    WHERE d.gender = 'm' AND (b.date::date - d.birth::date) > 912.5
      AND d.species = d1.species;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.PotentialDam_Insert() RETURNS void AS $$
BEGIN
    TRUNCATE TABLE onprc_ehr.PotentialDam_source;
    INSERT INTO onprc_ehr.PotentialDam_source
    (participantId, Date, Species, room, cage, DamAgeAtTime, PotentialDam, DamBirth, Damgender, DamSpecies, DamDeath, created, createdBy, modified, modifiedBy, container)
    SELECT
        b.participantid,
        b.date,
        b.species,
        b.room,
        b.cage,
        (b.date::date - d.birth::date) / 365,
        h.participantID,
        d.birth,
        d.gender,
        d.species,
        d.death,
        now(),
        1011,
        now(),
        1011,
        'CD17027B-C55F-102F-9907-5107380A54BE'::entityid
    FROM studyDataset.c6d202_birth b
             JOIN studyDataset.c6d194_housing h ON
        (b.participantId <> h.participantId AND
         (h.date <= b.date AND h.enddate >= b.date) AND
         h.room = b.room AND (h.cage = b.cage OR (h.cage IS NULL AND b.cage IS NULL))
            OR h.participantid = b.dam
            )
             JOIN studyDataset.c6d203_demographics d ON d.participantid = h.participantid
             JOIN studyDataset.c6d203_demographics d1 ON d1.participantID = b.participantid
    WHERE d.gender = 'f' AND (b.date::date - d.birth::date) > 912.5
      AND d.species = d1.species;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.StudyDetails_Reference_Data(
    rowId SERIAL NOT NULL,
    value varchar(1000) NULL,
    name varchar(1000) NULL,
    remark varchar(4000) NULL,
    sort_order INT NULL,
    dateDisabled TIMESTAMP NULL,
    created TIMESTAMP NULL,
    createdBy int NULL,
    modified TIMESTAMP NULL,
    modifiedBy int NULL,

    CONSTRAINT pk_StudyDetails_Reference_Data PRIMARY KEY (rowId)
);

CREATE TABLE onprc_ehr.availableCages_temp(
    location varchar(50) NOT NULL,
    room varchar(200) NULL,
    cage varchar(200) NULL,
    row varchar(200) NULL,
    columnidx int NULL,
    cage_type varchar(200) NULL,
    lowerCage varchar(200) NULL,
    lower_cage_type varchar(200) NULL,
    divider int NULL,
    isAvailable int NULL,
    isMarkedUnavailable int NULL
);

CREATE TABLE onprc_ehr.availableCagesByRoom_temp(
    room varchar(200) NULL,
    availableCages int NULL,
    markedUnavailable int NULL
);

CREATE TABLE onprc_ehr.roomUtilization_temp(
    room varchar(200) NULL,
    availableCages int NULL,
    cagesUsed int NULL,
    markedUnavailable int NULL,
    cagesEmpty int NULL,
    totalAnimals int NULL
);

CREATE OR REPLACE FUNCTION onprc_ehr.NHPRoomsUsage() RETURNS void AS $$
BEGIN
    DELETE FROM onprc_ehr.availableCages_temp;

    INSERT INTO onprc_ehr.availableCages_temp(location, room, cage, row, columnidx, cage_type, lowerCage, lower_cage_type, divider, isAvailable, isMarkedUnavailable)
    SELECT
        CASE
            WHEN c.cage IS NULL THEN c.room
            ELSE (c.room || '-' || c.cage)
            END as location,
        c.room,
        c.cage,
        (SELECT cp.row FROM ehr_lookups.cage_positions cp WHERE c.cage = cp.cage) as row,
        (SELECT cp.columnIdx FROM ehr_lookups.cage_positions cp WHERE c.cage = cp.cage) as columnidx,
        c.cage_type,
        lc.cage as lowerCage,
        lc.cage_type as lower_cage_type,
        lc.divider,
        CASE
            WHEN c.cage_type = 'No Cage' THEN 0
            WHEN (SELECT d.countAsSeparate FROM ehr_lookups.divider_types d WHERE lc.divider = d.rowid) = 0 THEN 0
            ELSE 1
            END as isAvailable,
        CASE
            WHEN (c.status IS NOT NULL AND c.status = 'Unavailable') THEN 1
            ELSE 0
            END as isMarkedUnavailable
    FROM ehr_lookups.cage c
         LEFT JOIN ehr_lookups.cage lc ON (lc.cage_type <> 'No Cage' AND c.room = lc.room AND (SELECT cp.row FROM ehr_lookups.cage_positions cp WHERE c.cage = cp.cage) = (SELECT cp.row FROM ehr_lookups.cage_positions cp WHERE lc.cage = cp.cage) AND ((SELECT cp.columnIdx FROM ehr_lookups.cage_positions cp WHERE c.cage = cp.cage) - 1) = (SELECT cp.columnIdx FROM ehr_lookups.cage_positions cp WHERE lc.cage = cp.cage) );

    DELETE FROM onprc_ehr.availableCagesByRoom_temp;

    INSERT INTO onprc_ehr.availableCagesByRoom_temp(room, availableCages, markedUnavailable)
    SELECT
        c.room,
        count(*) as availableCages,
        sum(c.isMarkedUnavailable) as markedUnavailable
    FROM onprc_ehr.availableCages_temp c
    WHERE c.isAvailable = 1
    GROUP BY c.room;

    DELETE FROM onprc_ehr.roomUtilization_temp;

    INSERT INTO onprc_ehr.roomUtilization_temp(room, availableCages, CagesUsed, MarkedUnavailable, CagesEmpty, TotalAnimals)
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
            WHERE cage IS NOT NULL
            UNION ALL
            SELECT r.room, NULL as cage
            FROM ehr_lookups.rooms r
        ) c ON (r.room = c.room)
         LEFT JOIN studyDataset.c6d194_housing h ON (r.room=h.room AND (c.cage=h.cage OR (c.cage IS NULL AND h.cage IS NULL)) AND (((h.date <= now() AND h.enddate >= now()) OR (h.date <= now() AND h.enddate IS NULL))))
         LEFT JOIN onprc_ehr.availableCagesByRoom_temp cbr ON (cbr.room = r.room)
    WHERE r.datedisabled IS NULL
    GROUP BY r.room;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.PMIC_Reference_Data(
    RowId SERIAL NOT NULL,
    value varchar(1000) NULL,
    name varchar(1000) NULL,
    remark varchar(4000) NULL,
    dateDisabled TIMESTAMP NULL,
    created TIMESTAMP NULL,
    createdBy int NULL,
    modified TIMESTAMP NULL,
    modifiedBy int NULL,

    CONSTRAINT pk_PMIC_Reference_Data PRIMARY KEY (RowId)
);

CREATE TABLE onprc_ehr.ASB_SpecialInstructions(
    value varchar(1000) NOT NULL,
    remarks varchar(2000) NULL,
    dateDisabled TIMESTAMP NULL,
    created TIMESTAMP NULL,
    createdBy int NULL,
    modified TIMESTAMP NULL,
    modifiedBy int NULL,

    CONSTRAINT pk_ASB_SpecialInstructions PRIMARY KEY (value)
);

CREATE TABLE onprc_ehr.Prima_Animals(
    Id int NOT NULL,
    AlternateIdentifier varchar(63) NULL,
    BreedId int NULL,
    DateOfBirth TIMESTAMP NULL,
    FecesId int NULL,
    Gender smallint NOT NULL,
    GeneTarget varchar(127) NULL,
    GeneticLine varchar(127) NULL,
    Genotype varchar(127) NULL,
    Identifier varchar(127) NULL,
    MannerOfDeathId int NULL,
    RoomNumber varchar(9) NULL,
    SpeciesId int NOT NULL,
    StomachContentsId int NULL,
    StrainId int NULL,
    DateOfDeath TIMESTAMP NULL,
    Created TIMESTAMPTZ NOT NULL,
    OwnerId int NULL,
    Perfuse BOOLEAN NOT NULL,
    SampleType smallint NOT NULL
);

CREATE TABLE onprc_ehr.Prima_TissueCollections(
    Id int NOT NULL,
    Constant smallint NULL,
    IsWholeAnimal BOOLEAN NOT NULL,
    SpeciesId int NOT NULL,
    SpecimenType int NOT NULL,
    CreatedByUserId int NOT NULL,
    Deleted TIMESTAMPTZ NULL,
    DeletedByUserId int NULL,
    NextVersionId int NULL,
    PreviousVersionId int NULL,
    Title varchar(127) NOT NULL,
    Created TIMESTAMPTZ NOT NULL,
    LastModified TIMESTAMP NOT NULL,
    Abbreviation varchar(127) NULL
);

CREATE TABLE onprc_ehr.Prima_CaseBase(
    Id int NOT NULL,
    DifferentialDiagnosisId int NULL,
    PathologistId int NULL,
    PriorityLevelId int NOT NULL,
    ResidentPathologistId int NULL,
    SerialNumber int NOT NULL,
    SurgeryDate TIMESTAMP NULL,
    SurgicalWheelId int NOT NULL,
    Created TIMESTAMPTZ NOT NULL,
    ResearcherId int NULL,
    StudyId int NULL,
    Discriminator varchar(128) NULL,
    StudyPhaseId int NULL,
    CohortId int NULL,
    SavedIdentifier text NULL,
    Status smallint NOT NULL,
    AlternateIdentifier varchar(24) NULL,
    SurgeryLocationId int NULL,
    ResearchPatientId int NULL,
    AnimalId int NULL,
    ClinicalPatientId int NULL,
    SurgeryAge varchar(31) NULL
);

CREATE TABLE onprc_ehr.Prima_CassetteBases(
    Id bigint NOT NULL,
    CassetteColorId int NOT NULL,
    EmbeddingInstructionId int NOT NULL,
    HasTissue BOOLEAN NOT NULL,
    ProtocolCassetteId int NULL,
    SpecimenBaseId bigint NOT NULL,
    TissueCollectionId int NULL,
    TissueProcessorProgramId int NULL,
    TissueQuantity smallint NOT NULL,
    CaseBaseId int NOT NULL,
    PriorityLevelId int NOT NULL,
    QcStatus smallint NOT NULL,
    SurgicalSerialPart smallint NOT NULL,
    Created TIMESTAMPTZ NOT NULL,
    OrderedStatus smallint NOT NULL,
    SavedIdentifier varchar(24) NULL,
    BarcodeContent varchar(72) NULL,
    AlternateIdentifier varchar(63) NULL,
    PrintStatus smallint NOT NULL,
    ItemStatus smallint NOT NULL,
    Hazard smallint NOT NULL,
    CurrentContainerId int NULL
);

CREATE OR REPLACE FUNCTION onprc_ehr.PrimaSlideBillingReport(
    startDate TIMESTAMP,
    endDate TIMESTAMP
)
RETURNS TABLE (
    "Surgical Wheel" varchar(5),
    "Pathologist" text,
    "Stain Test" varchar(127),
    "Slide Count" bigint
) AS $$
DECLARE
    staining int;
    embedding int;
    complete int;
BEGIN
    staining := (SELECT id FROM onprc_ehr.Prima_LabstationTypes WHERE Constant = 10);
    embedding := (SELECT id FROM onprc_ehr.Prima_LabstationTypes WHERE Constant = 7);
    complete := 7;

    RETURN QUERY
    SELECT 
        Prima_surgicalwheels.title::varchar(5) AS "Surgical Wheel",
        CASE
            WHEN Prima_userpersons.lastname IS NOT NULL THEN
                (Prima_userpersons.lastname || ', ' || Prima_userpersons.firstname || ' ' || COALESCE(Prima_userpersons.middlename, ''))::text
            ELSE 'Unassigned Pathologist'::text
        END AS "Pathologist",
        Prima_staintests.title::varchar(127) AS "Stain Test",
        sub2.slidecount::bigint AS "Slide Count"
    FROM (
        SELECT 
            surgicalwheelid,
            Prima_slidebases.staintestid,
            Prima_casebase.pathologistid,
            Count(*) AS SlideCount
        FROM (
            SELECT Min(Prima_slideevents.created) AS VerifyOrBarcodeEventTime,
                   slidebaseid
            FROM onprc_ehr.Prima_slideevents 
            JOIN onprc_ehr.Prima_SlideEventLocations ON Prima_slideeventlocations.SlideEventId = Prima_slideevents.id
                AND Prima_slideeventlocations.LabStationTypeId = staining 
            WHERE eventtype = complete
            GROUP BY slidebaseid
        ) sub
        JOIN onprc_ehr.Prima_slidebases ON slidebaseid = Prima_slidebases.id
        JOIN onprc_ehr.Prima_casebase ON Prima_casebase.id = Prima_slidebases.casebaseid 
        WHERE sub.verifyorbarcodeeventtime >= startDate
          AND sub.verifyorbarcodeeventtime < endDate
        GROUP BY surgicalwheelid, pathologistid, staintestid
    ) sub2
    LEFT JOIN onprc_ehr.Prima_userpersons ON Prima_userpersons.id = sub2.pathologistid
    LEFT JOIN onprc_ehr.Prima_surgicalwheels ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    LEFT JOIN onprc_ehr.Prima_staintests ON Prima_staintests.id = sub2.staintestid
    ORDER BY "Surgical Wheel", "Pathologist", "Stain Test";
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.PrimaBlockBillingReport(
    startDate TIMESTAMP,
    endDate TIMESTAMP
)
RETURNS TABLE (
    "Surgical Wheel" varchar(5),
    "Pathologist" text,
    "Cassette Count" bigint
) AS $$
DECLARE
    staining int;
    embedding int;
    complete int;
BEGIN
    staining := (SELECT id FROM onprc_ehr.Prima_LabstationTypes WHERE Constant = 10);
    embedding := (SELECT id FROM onprc_ehr.Prima_LabstationTypes WHERE Constant = 7);
    complete := 7;

    RETURN QUERY
    SELECT 
        Prima_surgicalwheels.title::varchar(5) AS "Surgical Wheel",
        CASE
            WHEN Prima_userpersons.lastname IS NOT NULL THEN
                (Prima_userpersons.lastname || ', ' || Prima_userpersons.firstname || ' ' || COALESCE(Prima_userpersons.middlename, ''))::text
            ELSE 'Unassigned Pathologist'::text
        END AS "Pathologist",
        sub2.cassettecount::bigint AS "Cassette Count"
    FROM (
        SELECT 
            surgicalwheelid,
            Prima_casebase.pathologistid,
            Count(*) AS CassetteCount
        FROM (
            SELECT Min(Prima_cassetteevents.created) AS VerifyOrBarcodeEventTime,
                   cassettebaseid
            FROM onprc_ehr.Prima_cassetteevents
            JOIN onprc_ehr.Prima_CassetteEventLocations ON Prima_CassetteEventLocations.CassetteEventId = Prima_cassetteevents.id
                AND Prima_CassetteEventLocations.LabStationTypeId = embedding 
            WHERE eventtype = complete
            GROUP BY cassettebaseid
        ) sub
        JOIN onprc_ehr.Prima_cassettebases ON cassettebaseid = Prima_cassettebases.id
        JOIN onprc_ehr.Prima_casebase ON Prima_casebase.id = Prima_cassettebases.casebaseid
        WHERE sub.verifyorbarcodeeventtime >= startDate
          AND sub.verifyorbarcodeeventtime < endDate
        GROUP BY surgicalwheelid, pathologistid
    ) sub2
    LEFT JOIN onprc_ehr.Prima_userpersons ON Prima_userpersons.id = sub2.pathologistid
    LEFT JOIN onprc_ehr.Prima_surgicalwheels ON Prima_surgicalwheels.id = sub2.surgicalwheelid
    ORDER BY "Surgical Wheel", "Pathologist";
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.StudyDetails_RandalData(
    id INT NOT NULL,
    Rh varchar(100) NULL,
    Cohort varchar(1000) NULL,
    PI varchar(100) NULL,
    Cohort_id INT NULL,
    subcohort varchar(100) NULL,
    grp varchar(100) NULL,
    grp_order INT NULL,
    grp_id INT NOT NULL,
    rhCode varchar(100) NULL,
    grpnm INT NULL,
    Sex varchar(100) NULL,
    cohortStart date NULL,
    cohortEnd date NULL,
    "Do" date NULL,
    DPC0 date NULL,
    contprog varchar(100) NULL,
    PIDO date NULL,
    DPTO date NULL,
    Birth date NULL,
    Nx_date date NULL,
    stims varchar(100) NULL,
    active varchar(100) NULL,
    CONSTRAINT pk_StudyDetails_Randal PRIMARY KEY (Id)
);

CREATE TABLE onprc_ehr.BSUageclass
(
    rowId SERIAL NOT NULL,
    label varchar(255) NULL,
    species varchar(255) NULL,
    gender varchar(5) NULL,
    ageclass INT NULL,
    min double precision NULL,
    max double precision NULL,
    sort_order INT NULL,
    dateDisabled TIMESTAMP NULL,

    CONSTRAINT PK_bsuageclass PRIMARY KEY (rowId)
);

CREATE TABLE onprc_ehr.Epoc_tests
(
    rowid SERIAL NOT NULL,
    testid varchar(500) NOT NULL,
    name varchar(500) NULL,
    units varchar(50) NULL,
    alias varchar(200) NULL,
    alertOnAbnormal BOOLEAN NULL,
    alertOnAny BOOLEAN NULL,
    includeInPanel BOOLEAN NULL,
    objectid ENTITYID NOT NULL,
    sort_order int NULL,
    container ENTITYID,

    CONSTRAINT PK_EpocTestsObject PRIMARY KEY (objectid)
);

CREATE TABLE onprc_ehr.Reference_Data_IDkey
(
    rowId SERIAL,
    displayName varchar(4000) DEFAULT NULL,
    idkey integer NOT NULL,
    columnName varchar(1000) NOT NULL,
    status integer NULL,
    type varchar(500) NULL,
    sort_order integer NULL,
    created TIMESTAMP NOT NULL,
    endDate TIMESTAMP DEFAULT NULL,

    CONSTRAINT pk_referenceIDkey PRIMARY KEY (idkey)
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_PopulateReferenceDataIDkey() RETURNS int AS $$
BEGIN
    TRUNCATE TABLE onprc_ehr.Reference_Data_IDkey;

    INSERT INTO onprc_ehr.Reference_Data_IDkey (displayName, idkey, columnName, status, type, sort_order, created, endDate)
    SELECT
        Name,
        UserId,
        'Active_Groups',
        Active,
        Type,
        NULL,
        now(),
        NULL
    FROM core.Principals
    WHERE type = 'g'
      AND UserId > 0
      AND Active = 1
      AND Container IS NULL;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.p_CageStatusupdates() RETURNS int AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ehr_lookups.cage) THEN
        UPDATE ehr_lookups.cage
        SET status = 'Normal'
        WHERE status IS NULL;
    END IF;
    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.CageAuditLog(
    searchid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    rowid int NULL,
    location varchar(100) NULL,
    room varchar(200) NULL,
    cage varchar(200) NULL,
    divider int NULL,
    cage_type varchar(100) NULL,
    hasTunnel BOOLEAN NULL,
    status varchar(200) NULL,
    Container ENTITYID NOT NULL,
    area varchar(500) NULL,
    housingtype varchar(500) NULL,
    housingcondition varchar(500) NULL,
    date_created TIMESTAMP NULL,

    CONSTRAINT pk_searchid PRIMARY KEY (searchid)
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_CageAuditHistoryProcess() RETURNS int AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM onprc_ehr.CageAuditLog) THEN
        INSERT INTO onprc_ehr.CageAuditLog (rowid, location, room, cage, divider, cage_type, hasTunnel, status, container, area, housingtype, housingcondition, date_created)
        SELECT  
            rowid,
            a.location,
            a.room,
            a.cage,
            a.divider,
            a.cage_type,
            a.hasTunnel,
            a.status,
            a.container,
            (SELECT h.area FROM ehr_lookups.rooms h WHERE h.room = a.room) as area,
            (SELECT s.value FROM ehr_lookups.rooms h, ehr_lookups.lookups s WHERE h.room = a.room AND s.rowid = h.housingtype) as housingtype,
            (SELECT s.value FROM ehr_lookups.rooms h, ehr_lookups.lookups s WHERE h.room = a.room AND s.rowid = h.housingcondition) as housingcondition,
            now()
        FROM ehr_lookups.cage a;
    END IF;
    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.Temp_ClnRemarks
(
    date TIMESTAMP,
    qcstate int,
    participantid varchar(32),
    project int,
    remark varchar(250) ,
    p varchar(250) ,
    performedby varchar(250) ,
    category varchar(250) ,
    taskid varchar(4000),
    createdby int,
    modifiedby int
);

CREATE TABLE onprc_ehr.Environmental_Reference_Data (
    rowId SERIAL,
    label varchar(250) DEFAULT NULL,
    value varchar(500) ,
    columnName varchar(255)  NOT NULL,
    sort_order integer NULL,
    endDate TIMESTAMP DEFAULT NULL,

    CONSTRAINT pk_referenceenv PRIMARY KEY (value)
);

CREATE TABLE onprc_ehr.Environmental_Assessment(
   rowid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
   date TIMESTAMP NULL,
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
   objectid ENTITYID NOT NULL,
   createdby int NULL,
   created TIMESTAMP NULL,
   modifiedby int NULL,
   modified TIMESTAMP NULL,
   Container ENTITYID NOT NULL,
   taskid  entityid,
   qcstate int NULL,
   formsort int NULL,

   CONSTRAINT PK_assessment PRIMARY KEY (objectid)
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_Environmental_Update_Process() RETURNS int AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'list' AND table_name = 'c8754d723_surface_sanitation_minus_rodac_48hr') THEN
        EXECUTE 'INSERT INTO onprc_ehr.Environmental_Assessment
        (date, testing_location, service_requested, test_type, colony_count, pass_fail, performedby, action, remarks, objectid, created, createdby, modified, modifiedby, qcstate, container)
        SELECT date, TestSite, ''Sanitation: Contact Plate'', TestType, ColonyCount, PassFail, CollectedBy, Action, comment, core.fn_nextid()::entityid, now(), 1896, now(), 1896, 18, ''98F39B23-5E3B-1037-AFE5-BD25D057100A''::entityid
        FROM list.c8754d723_surface_sanitation_minus_rodac_48hr';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'list' AND table_name = 'c8754d726_h2o_testing') THEN
        EXECUTE 'INSERT INTO onprc_ehr.Environmental_Assessment
        (date, testing_location, service_requested, water_source, test_type, test_results, pass_fail, remarks, objectid, created, createdby, modified, modifiedby, qcstate, container)
        SELECT date, TestSite, ''Sanitation: Water Test'', H2OSource, TestType, result, PassFail, comment, core.fn_nextid()::entityid, now(), 1896, now(), 1896, 18, ''98F39B23-5E3B-1037-AFE5-BD25D057100A''::entityid
        FROM list.c8754d726_h2o_testing';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'list' AND table_name = 'c8754d795_biological_indicator_log') THEN
        EXECUTE 'INSERT INTO onprc_ehr.Environmental_Assessment
        (date, testing_location, service_requested, biological_Cycle, biological_BI, pass_fail, retest, action, performedby, remarks, objectid, created, createdby, modified, modifiedby, qcstate, container)
        SELECT date, autoclave, ''Sanitation: Bio-indicator'', "cycle (if applicable)", "BI# (for ASA)", "Pass / Fail", "Results Read by", action, "Collected By", comment, core.fn_nextid()::entityid, now(), 1896, now(), 1896, 18, ''98F39B23-5E3B-1037-AFE5-BD25D057100A''::entityid
        FROM list.c8754d795_biological_indicator_log';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'list' AND table_name = 'c8754d731_atp_testing') THEN
        EXECUTE 'INSERT INTO onprc_ehr.Environmental_Assessment
        (date, performedby, service_requested, testing_location, surface_tested, pass_fail, remarks, retest, test_results, action, objectid, created, createdby, modified, modifiedby, qcstate, container)
        SELECT date, Tech_Initials, ''Sanitation: ATP'', area, Surface, initial, comments, retest, Lab_Group, location, core.fn_nextid()::entityid, now(), 1896, now(), 1896, 18, ''98F39B23-5E3B-1037-AFE5-BD25D057100A''::entityid
        FROM list.c8754d731_atp_testing';
    END IF;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.p_EnvironmentalHistoricalUpdates() RETURNS int AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM onprc_ehr.Environmental_Assessment) THEN
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL SW' WHERE testing_location = 'Col. SW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 1', charge_unit = 'Clinpath' WHERE testing_location = 'Annex Rm 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL SW', charge_unit = 'Clinpath' WHERE testing_location = 'Colony SW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Catch Area 2', charge_unit = 'Clinpath' WHERE testing_location = 'Catch 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 1 Lixit' WHERE testing_location = 'Pens Run 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 10 Lixit' WHERE testing_location = 'Pens Run 10';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 11 Lixit' WHERE testing_location = 'Pens Run 11';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 12 Lixit' WHERE testing_location = 'Pens Run 12';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 2 Lixit' WHERE testing_location = 'Pens Run 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 3 Lixit' WHERE testing_location = 'Pens Run 3';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 4 Lixit' WHERE testing_location = 'Pens Run 4';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 5 Lixit' WHERE testing_location = 'Pens Run 5';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 6 Lixit' WHERE testing_location = 'Pens Run 6';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 7 Lixit' WHERE testing_location = 'Pens Run 7';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 8 Lixit' WHERE testing_location = 'Pens Run 8';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens Run 9 Lixit' WHERE testing_location = 'Pens Run 9';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 1 Lixit' WHERE testing_location = 'SGH 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 10 Lixit' WHERE testing_location = 'SGH 10';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 11 Lixit' WHERE testing_location = 'SGH 11';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 12 Lixit' WHERE testing_location = 'SGH 12';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 13 Lixit' WHERE testing_location = 'SGH 13';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 14 Lixit' WHERE testing_location = 'SGH 14';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 15 Lixit' WHERE testing_location = 'SGH 15';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 16 Lixit' WHERE testing_location = 'SGH 16';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 17 Lixit' WHERE testing_location = 'SGH 17';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 18 Lixit' WHERE testing_location = 'SGH 18';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 19 Lixit' WHERE testing_location = 'SGH 19';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 2 Lixit' WHERE testing_location = 'SGH 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 20 Lixit' WHERE testing_location = 'SGH 20';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 21 Lixit' WHERE testing_location = 'SGH 21';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 22 Lixit' WHERE testing_location = 'SGH 22';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 23 Lixit' WHERE testing_location = 'SGH 23';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 24 Lixit' WHERE testing_location = 'SGH 24';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 25 Lixit' WHERE testing_location = 'SGH 25';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 26 Lixit' WHERE testing_location = 'SGH 26';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 27 Lixit' WHERE testing_location = 'SGH 27';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 28 Lixit' WHERE testing_location = 'SGH 28';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 29 Lixit' WHERE testing_location = 'SGH 29';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 30 Lixit' WHERE testing_location = 'SGH 30';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 3 Lixit' WHERE testing_location = 'SGH 3';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 31 Lixit' WHERE testing_location = 'SGH 31';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 32 Lixit' WHERE testing_location = 'SGH 32';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 4 Lixit' WHERE testing_location = 'SGH 4';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 5 Lixit' WHERE testing_location = 'SGH 5';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 6 Lixit' WHERE testing_location = 'SGH 6';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 7 Lixit' WHERE testing_location = 'SGH 7';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 8 Lixit' WHERE testing_location = 'SGH 8';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 9 Lixit' WHERE testing_location = 'SGH 9';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'BOS RM 102' WHERE testing_location = 'Bosky 102';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'BOS RM 103' WHERE testing_location = 'Bosky 103';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'BOS RM 104' WHERE testing_location = 'Bosky 104';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'BOS RM 122' WHERE testing_location = 'Bosky 122';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'BOS RM 123' WHERE testing_location = 'Bosky 123';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer Colony Annex toy' WHERE testing_location = 'Cage Washer Colony Annex tunnel toy';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer VGTI Large (Jan/June)' WHERE testing_location = 'Cage Washer VGTI Large (semi-annual)';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer VGTI Small (Jan/June)' WHERE testing_location = 'Cage Washer VGTI Small (semi-annual)';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher Colony North' WHERE testing_location = 'Dishwasher N. Colony';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher Colony South' WHERE testing_location = 'Dishwasher S. Colony';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 37' WHERE testing_location = 'Annex room 37';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Catch Area 2' WHERE testing_location = 'Catch 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Catch Area 5' WHERE testing_location = 'Catch 5';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL SW' WHERE testing_location = 'Col. SW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL NW' WHERE testing_location = 'Col. NW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL NW' WHERE testing_location = 'Colony NW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL RM 4' WHERE testing_location = 'Colony RM 4';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 1' WHERE testing_location = 'Colony Run 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 2' WHERE testing_location = 'Colony Run 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 3' WHERE testing_location = 'Colony Run 3';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 4' WHERE testing_location = 'Colony Run 4';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 5' WHERE testing_location = 'Colony Run 5';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 6' WHERE testing_location = 'Colony Run 6';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 7' WHERE testing_location = 'Colony Run 7';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL Run 8' WHERE testing_location = 'Colony Run 8';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'COL SW' WHERE testing_location = 'Colony SW';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 1' WHERE testing_location = 'SGH 1  inside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 1' WHERE testing_location = 'SGH 1 inside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 2' WHERE testing_location = 'SGH 2  outside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 2' WHERE testing_location = 'SGH 2 outside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 29' WHERE testing_location = 'SGH 29  inside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 29' WHERE testing_location = 'SGH 29 inside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 30' WHERE testing_location = 'SGH 30  outside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'SGH 30' WHERE testing_location = 'SGH 30 outside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher Bldg 611 ' WHERE testing_location = 'SGH 30 outside';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher ASA 135' WHERE testing_location = 'Dishwasher ASA 135 ';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher ASA 136' WHERE testing_location = 'Dishwasher ASA 136 ';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Dishwasher Bldg 611' WHERE testing_location = 'Dishwasher Bldg 611 ';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 1' WHERE testing_location = 'AN RM 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 34' WHERE testing_location = 'AN RM 34';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 13' WHERE testing_location = 'AN RM 13';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 14' WHERE testing_location = 'AN RM 14';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 15' WHERE testing_location = 'AN RM 15';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 16' WHERE testing_location = 'AN RM 16';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 2' WHERE testing_location = 'AN RM 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 34' WHERE testing_location = 'AN RM 34';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 39' WHERE testing_location = 'AN RM 39';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Rm 4' WHERE testing_location = 'AN RM 4';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Run 1' WHERE testing_location = 'AN RUN 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Run 2' WHERE testing_location = 'AN RUN 2';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Run 3' WHERE testing_location = 'AN RUN 3';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Annex Run 30' WHERE testing_location = 'AN RUN 30';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 7E' WHERE testing_location = 'Col Run 7 E';

        UPDATE onprc_ehr.Environmental_Assessment
        SET charge_unit = 'Clinpath'
        WHERE testing_location IN (SELECT DISTINCT value FROM onprc_ehr.Environmental_Reference_Data WHERE columnname = 'testlocation');

        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 7A' WHERE testing_location = 'Col Run 7 A';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 7B' WHERE testing_location = 'Col Run 7 B';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 7D' WHERE testing_location = 'Col Run 7 D';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Colony Rm 2 (Clinic)' WHERE testing_location = 'Colony Rm 2 Clinic';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens RM 102A  (Clinic)' WHERE testing_location = 'Pens Rm 102A (Clinic)';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens RM 104 (Feed)' WHERE testing_location = 'PENS Rm 104 (Feed Room)';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Pens RM 104 (Feed)' WHERE testing_location = 'Pens RM 104 (Feed )';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'VGTI 0120 (clean cage wash)' WHERE testing_location = 'VGTI 0120 (clean cage wash';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 6A' WHERE testing_location = 'Col Run 6 A';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Col Run 6C' WHERE testing_location = 'Col Run 6 C';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'ASB 3 Cage Wash' WHERE testing_location = 'ASB 3 Cage Wash Area';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'ASB 1 Cage Wash' WHERE testing_location = 'ASB 1 Cage Wash Area';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer ASB 1 cage' WHERE testing_location = 'Cage Washer ASB 1';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer VGTI Large (Jan/June)' WHERE testing_location = 'Cage Washer VGTI Large';
        UPDATE onprc_ehr.Environmental_Assessment SET testing_location = 'Cage Washer VGTI Small (Jan/June)' WHERE testing_location = 'Cage Washer VGTI Small';
    END IF;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.MPA_ClnRemarkAddition() RETURNS void AS $$
DECLARE
    MPACount Int;
    taskId varchar(4000);
    displayName varchar(250);
BEGIN
    DELETE FROM onprc_ehr.Temp_ClnRemarks;

    SELECT COUNT(*) INTO MPACount FROM studyDataset.c6d178_drug
    WHERE code = 'E-85760' AND date::date = now()::date AND qcstate = 18;

    IF MPACount > 0 THEN
        SELECT u.displayName INTO displayName FROM core.users u WHERE u.userid = 1003;

        taskId := core.fn_nextid();

        INSERT INTO ehr.tasks
        (taskid, category, title, formtype, qcstate, assignedto, duedate, createdby, created,
         container, modifiedby, modified, description, datecompleted)
        VALUES
        (taskId, 'Task', 'Bulk Clinical Entry', 'Bulk Clinical Entry', 18, 1003, now(), 1003, now(),
         'CD17027B-C55F-102F-9907-5107380A54BE'::entityid, 1003, now(), 'Created by the ETL process', now());

        INSERT INTO onprc_ehr.Temp_ClnRemarks (
            date, qcstate, participantid, project, remark, p, performedby, category, taskid, createdby, modifiedby
        )
        SELECT now(), 18, participantid, project, 'Remark entered by the ETL process', 'MPA injection administered', displayName, 'Clinical', taskId, 1003, 1003
        FROM studyDataset.c6d178_drug
        WHERE code = 'E-85760' AND date::date = now()::date AND qcstate = 18;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.TB_TestTemp(
    rowid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    animalid varchar(200) NULL,
    date TIMESTAMP NULL,
    objectid ENTITYID NOT NULL,
    created TIMESTAMP NULL,
    createdby integer NULL,
    performedby varchar(200) NULL
);

CREATE TABLE onprc_ehr.TB_TestTempMaster(
    rowid integer ,
    animalid varchar(200) NULL,
    date TIMESTAMP NULL,
    objectid ENTITYID NOT NULL,
    created TIMESTAMP NULL,
    createdby integer NULL,
    performedby varchar(200) NULL
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_Create_TB_Observationrecords() RETURNS int AS $$
DECLARE
    r RECORD;
    taskId varchar(4000);
    runId varchar(4000);
    obsDate TIMESTAMP;
BEGIN
    TRUNCATE TABLE onprc_ehr.TB_TestTemp;

    INSERT INTO onprc_ehr.TB_TestTemp (animalid, date, objectid, created, createdby, performedby)
    SELECT
        a.participantid,
        a.date,
        a.objectid,
        a.created,
        a.createdBy,
        a.performedby
    FROM studydataset.c6d214_encounters a
    WHERE a.participantid NOT IN (
        SELECT b.participantid 
        FROM studydataset.c6d171_clinical_observations b
        WHERE a.participantid = b.participantid 
          AND b.date::date = (a.date::date + INTERVAL '3 days')::date 
          AND b.category = 'TB TST Score (72 hr)'
          AND a.created >= now()::date
          AND a.type = 'Procedure' 
          AND a.qcstate = 18 
          AND a.procedureid = 802
    )
      AND a.type = 'Procedure' 
      AND a.qcstate = 18 
      AND a.procedureid = 802
      AND a.created >= now()::date
      AND a.participantid IN (
        SELECT k.participantid 
        FROM studydataset.c6d203_demographics k
        WHERE k.calculated_status = 'alive'
      )
    ORDER BY a.participantid, a.date DESC;

    IF NOT EXISTS (SELECT 1 FROM onprc_ehr.TB_TestTemp) THEN
        RETURN 0;
    END IF;

    taskId := core.fn_nextid();

    INSERT INTO EHR.Tasks (
        taskid, description, title, qcstate, formType, category, container, assignedto, created, createdby, modified, modifiedby
    )
    VALUES (
        taskId,
        'TB TST Scores ' || COALESCE(obsDate::text, ''),
        'TB TST Scores',
        20,
        'TB TST Scores',
        'task',
        'CD17027B-C55F-102F-9907-5107380A54BE'::entityid,
        1822,
        now(),
        1042,
        now(),
        1042
    );

    FOR r IN SELECT * FROM onprc_ehr.TB_TestTemp LOOP
        obsDate := r.date + INTERVAL '3 days';
        
        IF NOT EXISTS (
            SELECT 1 FROM studydataset.c6d171_clinical_observations j 
            WHERE j.participantid = r.animalid
              AND j.date::date = obsDate::date 
              AND j.category = 'TB TST Score (72 hr)'
        ) THEN
            runId := core.fn_nextid();

            INSERT INTO studydataset.c6d171_clinical_observations (
                participantid, date, category, area, observation, created, createdby, performedby, objectid, taskid, qcstate, modified, modifiedby, lsid
            )
            VALUES (
                r.animalid,
                obsDate,
                'TB TST Score (72 hr)',
                'Right Eyelid',
                'Grade: Negative',
                now(),
                r.createdby,
                r.performedby,
                runId,
                taskId,
                20,
                now(),
                r.createdby,
                'urn:lsid:ohsu.edu:Study.Data-6:5006.10003.19810204.0000.' || runId
            );
        END IF;
    END LOOP;

    INSERT INTO onprc_ehr.TB_TestTempMaster (rowid, animalid, date, objectid, created, createdby, performedby)
    SELECT rowid, animalid, date, objectid, created, createdby, performedby 
    FROM onprc_ehr.TB_TestTemp;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.BaseProtocol() RETURNS void AS $$
BEGIN
    WITH BaseProtocol_CTE AS (
         SELECT
             RowID,
             Protocol_id,
             CASE
                 WHEN LENGTH(Protocol_id) > 10 THEN SUBSTRING(Protocol_id, 6, 15)
                 ELSE Protocol_id
                 END AS BaseProtocolVal,
             CASE
                 WHEN LENGTH(Protocol_id) > 10 THEN SUBSTRING(Protocol_id, 1, 5)
                 ELSE 'Original'
                 END AS RevisionNumberVal
         FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    )
    UPDATE onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
    SET BaseProtocol = bp.BaseProtocolVal,
        RevisionNumber = bp.RevisionNumberVal
    FROM BaseProtocol_CTE bp
    WHERE p.RowID = bp.RowID;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION onprc_ehr.ExpiredProtocolUpdate() RETURNS void AS $$
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
                            AND p.Approval_Date = ap.maxApprovalDate
    ),
    ExpiredProtocol AS (
        SELECT
            d.*,
            p.protocol,
            p.enddate
        FROM DistinctProtocols d 
        INNER JOIN ehr.protocol p ON d.BaseProtocol = p.external_ID
        WHERE d.Protocol_State <> 'Approved' AND p.enddate IS NULL
    )
    UPDATE ehr.protocol p
    SET enddate = now()
    FROM ExpiredProtocol e
    WHERE p.external_id = e.BaseProtocol;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.procedure_default_blood (
  rowid SERIAL,
  procedureid  int,
  sampletype varchar(300) NULL,
  additionalServices varchar(1000) NULL,
  reason varchar(300) NULL,
  instructions varchar(2000) NULL,
  chargetype varchar(400) NULL,

  CONSTRAINT PK_procedure_default_blood PRIMARY KEY (rowid)
);

CREATE TABLE onprc_ehr.Rpt_AnimalID_Weights(
    searchid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    animalID varchar(100) NULL,
    date TIMESTAMP NULL,
    weight decimal(12,5) NULL,
    taskId ENTITYID NULL,
    created TIMESTAMP NULL,
    createdby smallint NULL,
    modified TIMESTAMP NULL,
    modifiedby smallint NULL
);

CREATE TABLE onprc_ehr.Rpt_AnimalID_WeightsMaster(
    searchid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    rowid int,
    animalID varchar(100) NULL,
    date TIMESTAMP NULL,
    weight decimal(12,5) NULL,
    taskId ENTITYID NULL,
    created TIMESTAMP NULL,
    createdby smallint NULL,
    modified TIMESTAMP NULL,
    modifiedby smallint NULL,
    actual_created TIMESTAMP NULL,
    remark varchar(1000) NULL
);

CREATE OR REPLACE FUNCTION onprc_ehr.sp_PathologyTissueWeightsProcess(
    StartDate TIMESTAMP,
    EndDate TIMESTAMP
) RETURNS int AS $$
DECLARE
    r RECORD;
    runId varchar(4000);
BEGIN
    DELETE FROM onprc_ehr.Rpt_AnimalID_Weights;

    INSERT INTO onprc_ehr.Rpt_AnimalID_Weights (animalID, date, weight, taskId, created, createdby, modified, modifiedby)
    SELECT
        e.participantid,
        e.date,
        e.weight,
        e.taskid,
        e.created,
        e.createdby,
        e.modified,
        e.modifiedby
    FROM studydataset.c6d174_tissue_samples e
    WHERE e.tissue = 'T-00010'
      AND e.date >= StartDate 
      AND e.date < (EndDate + INTERVAL '1 day')
      AND e.qcstate = 18
      AND e.weight IS NOT NULL
    ORDER BY date DESC;

    FOR r IN SELECT * FROM onprc_ehr.Rpt_AnimalID_Weights LOOP
        IF NOT EXISTS (
            SELECT 1 FROM studydataset.c6d175_weight
            WHERE participantid = r.animalID AND date = r.date
        ) THEN
            runId := core.fn_nextid();

            INSERT INTO studydataset.c6d175_weight (
                participantid, date, weight, qcstate, created, createdby, modified, modifiedby, taskid, objectid, remark, lsid
            )
            VALUES (
                r.animalID,
                r.date,
                r.weight / 1000.0,
                18,
                r.created,
                r.createdby,
                r.modified,
                r.modifiedby,
                r.taskId,
                runId,
                'Weight added from Path Tissue records',
                'urn:lsid:ohsu.edu:Study.Data-6:1045.' || r.animalID || '.' || to_char(r.date::date, 'YYYYMMDD') || '.0000.' || runId
            );
        END IF;
    END LOOP;

    INSERT INTO onprc_ehr.Rpt_AnimalID_WeightsMaster (rowid, animalID, date, weight, taskId, created, createdby, modified, modifiedby, actual_created, remark)
    SELECT searchid, animalID, date, weight, taskId, created, createdby, modified, modifiedby, now(), 'Pathology Tissue Weight entry'
    FROM onprc_ehr.Rpt_AnimalID_Weights;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues(
    Searchkey SERIAL NOT NULL,
    animalID varchar(100) NULL,
    date TIMESTAMP NULL
);

CREATE TABLE onprc_ehr.Rpt_AnimalIDTissues_Master(
    rowid SERIAL NOT NULL,
    SearchID int NULL,
    animalID varchar(100) NULL,
    date TIMESTAMP NULL,
    actual_Created TIMESTAMP NULL,
    remarks varchar(500)
);

CREATE OR REPLACE FUNCTION onprc_ehr.sp_RptNecropsyTissueDistributionUpdates(
    StartDate TIMESTAMP,
    EndDate TIMESTAMP
) RETURNS int AS $$
DECLARE
    r RECORD;
    taskId varchar(4000);
BEGIN
    DELETE FROM onprc_ehr.Rpt_AnimalIDTissues;

    INSERT INTO onprc_ehr.Rpt_AnimalIDTissues (animalID, date)
    SELECT DISTINCT
        e.participantid,
        e.date
    FROM studydataset.c6d265_tissuedistributions e
    WHERE e.date >= StartDate 
      AND e.date < (EndDate + INTERVAL '1 day')
      AND e.qcstate = 18
    ORDER BY e.participantid, e.date;

    FOR r IN SELECT * FROM onprc_ehr.Rpt_AnimalIDTissues LOOP
        taskId := core.fn_nextid();

        INSERT INTO EHR.Tasks (
            taskid, description, title, qcstate, formType, category, container, assignedto, created, createdby, modified, modifiedby
        )
        VALUES (
            taskId,
            'Path Tissues ' || COALESCE(r.date::text, ''),
            'PathologyTissues',
            18,
            'PathologyTissues',
            'task',
            'CD17027B-C55F-102F-9907-5107380A54BE'::entityid,
            1693,
            now(),
            1042,
            now(),
            1042
        );

        UPDATE studydataset.c6d265_tissuedistributions
        SET taskid = taskId
        WHERE participantid = r.animalID AND date = r.date;
    END LOOP;

    INSERT INTO onprc_ehr.Rpt_AnimalIDTissues_Master (SearchID, animalID, date, actual_Created, remarks)
    SELECT Searchkey, animalID, date, now(), 'Tissue Distribution entries'
    FROM onprc_ehr.Rpt_AnimalIDTissues;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.snomed_counter
(
    subset varchar(255) NOT NULL,
    count integer NOT NULL,
    prefix varchar(10) NOT NULL,
    container entityid,
    createdby userid,
    created TIMESTAMP,
    modifiedby userid,
    modified TIMESTAMP,

    CONSTRAINT pk_snomed_counter PRIMARY KEY (subset),
    CONSTRAINT fk_onprc_snomed_counter_container FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
);

CREATE TABLE onprc_ehr.CenterProjectsTemp(
    searchid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    project smallint NULL,
    protocol varchar(400) NULL,
    account varchar(1000) NULL,
    title varchar(2000) NULL,
    research smallint NULL,
    createdby smallint NULL,
    created TIMESTAMP NULL,
    modified TIMESTAMP NULL,
    modifiedby smallint NULL,
    startdate TIMESTAMP NULL,
    enddate TIMESTAMP NULL,
    displayname varchar(1000) NULL,
    investigatorid smallint NULL,
    use_category varchar(500) NULL,
    projecttype varchar(500) NULL,
    objectid text NULL,
    date_posted TIMESTAMP NULL
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_CenterProjectsHistoricalProcess(
    InitialDate TIMESTAMP
) RETURNS int AS $$
BEGIN
    IF (now()::date = InitialDate::date) THEN
        INSERT INTO onprc_ehr.CenterProjectsTemp (
            project, protocol, account, title, research, createdby, created, modified, modifiedby, startdate, enddate, displayname, investigatorid, use_category, projecttype, objectid, date_posted
        )
        SELECT
            project,
            protocol::varchar(400),
            account,
            title,
            research,
            createdby,
            created,
            modified,
            modifiedby,
            startdate,
            enddate,
            name,
            investigatorid,
            use_category,
            projecttype,
            objectid,
            now()
        FROM ehr.project 
        WHERE (enddate IS NULL OR enddate >= now())
        ORDER BY modified;
    END IF;

    IF EXISTS (
        SELECT 1 FROM ehr.project 
        WHERE (enddate IS NULL OR enddate >= now()) AND modified >= now()::date
    ) THEN
        INSERT INTO onprc_ehr.CenterProjectsTemp (
            project, protocol, account, title, research, createdby, created, modified, modifiedby, startdate, enddate, displayname, investigatorid, use_category, projecttype, objectid, date_posted
        )
        SELECT
            project,
            protocol::varchar(400),
            account,
            title,
            research,
            createdby,
            created,
            modified,
            modifiedby,
            startdate,
            enddate,
            name,
            investigatorid,
            use_category,
            projecttype,
            objectid,
            now()
        FROM ehr.project 
        WHERE (enddate IS NULL OR enddate >= now()) AND modified >= now()::date
        ORDER BY modified;
    END IF;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE onprc_ehr.pairing_observation_types (
     rowid INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
     value varchar(200),
     category varchar(200),
     editorconfig text,
     schemaname varchar(200),
     queryname varchar(200),
     valuecolumn varchar(200),
     Created TIMESTAMP,
     CreatedBy USERID,
     Modified TIMESTAMP,
     ModifiedBy USERID,
     Container entityId NOT NULL,

     CONSTRAINT PK_ONPRC_EHR_PAIRING_OBSERVATION_TYPES PRIMARY KEY (rowid)
);

CREATE OR REPLACE FUNCTION onprc_ehr.p_BirthGeographicOriginUpdates() RETURNS int AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM studydataset.c6d202_birth bir
        JOIN studydataset.c6d512_geneticancestry b ON bir.participantid = b.participantid
        WHERE b.enddate IS NULL
          AND bir.qcstate = 18
          AND b.qcstate = 18
          AND bir.geographic_origin <> b.result
          AND b.result IS NOT NULL
    ) THEN
        UPDATE studydataset.c6d202_birth bir
        SET geographic_origin = b.result,
            modified = now(),
            modifiedby = b.modifiedby
        FROM studydataset.c6d512_geneticancestry b
        WHERE bir.participantid = b.participantid
          AND b.enddate IS NULL
          AND bir.qcstate = 18
          AND b.qcstate = 18
          AND bir.geographic_origin <> b.result
          AND b.result IS NOT NULL;
    END IF;

    RETURN 0;
EXCEPTION WHEN OTHERS THEN
    RETURN 1;
END;
$$ LANGUAGE plpgsql;
