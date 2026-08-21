CREATE SCHEMA extscheduler;

CREATE TABLE extscheduler.Resources
(
    Id SERIAL NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Color VARCHAR(20),

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_resources PRIMARY KEY (Id),
    CONSTRAINT UQ_resources_ContainerName UNIQUE (Container, Name)
);

CREATE TABLE extscheduler.Events
(
    Id SERIAL NOT NULL,
    ResourceId INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NOT NULL,
    UserId USERID NOT NULL,

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_events PRIMARY KEY (Id),
    CONSTRAINT FK_events_ResourceId FOREIGN KEY (ResourceId) REFERENCES extscheduler.Resources(Id),
    CONSTRAINT UQ_events_ContainerResourceName UNIQUE (Container, ResourceId, Name)
);

/* 15.xxx SQL scripts */

ALTER TABLE extscheduler.Resources ADD Room VARCHAR(255);
ALTER TABLE extscheduler.Resources ADD Bldg VARCHAR(255);

ALTER TABLE extscheduler.Events ADD Alias VARCHAR(25);

CREATE TABLE extscheduler.users
(
    Id SERIAL NOT NULL,
    PrimeUserID USERID NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(255),
    Department VARCHAR(255),
    Lab_FirstName VARCHAR(255),
    Lab_LastName VARCHAR(255),
    FiscalAuthority_Name VARCHAR(255),
    FiscalAuthority_Phone VARCHAR(255),
    SecurityLevel VARCHAR(255),
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_users PRIMARY KEY (Id),
    CONSTRAINT FK_users_PrimeUserID FOREIGN KEY (PrimeUserID) REFERENCES core.Usersdata(UserId),
    CONSTRAINT UQ_users_ContainerPrimeUserID UNIQUE (Container, PrimeUserID)
);

DROP TABLE extscheduler.users;

CREATE TABLE extscheduler.users
(
    Id SERIAL NOT NULL,
    PrimeUserID USERID NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(255),
    Department VARCHAR(255),
    Lab_FirstName VARCHAR(255),
    Lab_LastName VARCHAR(255),
    FiscalAuthority_Name VARCHAR(255),
    FiscalAuthority_Phone VARCHAR(255),
    SecurityLevel VARCHAR(255),
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_users PRIMARY KEY (Id),
    CONSTRAINT FK_users_PrimeUserID FOREIGN KEY (PrimeUserID) REFERENCES core.Usersdata(UserId),
    CONSTRAINT UQ_users_ContainerPrimeUserID UNIQUE (Container, PrimeUserID)
);

ALTER TABLE extscheduler.events DROP CONSTRAINT UQ_events_ContainerResourceName;
ALTER TABLE extscheduler.events ADD CONSTRAINT CHK_event_DateRangeValid CHECK (StartDate <= EndDate);

CREATE OR REPLACE FUNCTION extscheduler.tr_overlappingdateranges() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        WHERE (R.Container = NEW.Container AND R.ResourceId = NEW.ResourceId AND R.StartDate < NEW.EndDate AND NEW.StartDate < R.EndDate)
          AND NOT (R.Container = NEW.Container AND R.ResourceId = NEW.ResourceId AND R.StartDate = NEW.StartDate AND NEW.EndDate = R.EndDate)
    ) THEN
        RAISE EXCEPTION 'Start/End date ranges may not overlap for the same resource.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_OverlappingDateRanges
    BEFORE INSERT OR UPDATE ON extscheduler.events
    FOR EACH ROW
    EXECUTE FUNCTION extscheduler.tr_overlappingdateranges();

ALTER TABLE extscheduler.events ALTER COLUMN Name DROP NOT NULL;

DROP TABLE extscheduler.users;

CREATE OR REPLACE FUNCTION extscheduler.tr_overlappingdateranges() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        WHERE (R.Container = NEW.Container AND R.ResourceId = NEW.ResourceId AND R.StartDate < NEW.EndDate AND NEW.StartDate < R.EndDate)
          AND NOT (R.Id = NEW.Id)
    ) THEN
        RAISE EXCEPTION 'Start/End date ranges may not overlap for the same resource.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE extscheduler.Events ADD Quantity INT;

ALTER TABLE extscheduler.Events ADD Comments VARCHAR(255);

CREATE OR REPLACE FUNCTION extscheduler.tr_overlappingdateranges() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1 FROM extscheduler.events R
        LEFT JOIN (
            SELECT ObjectId, Value FROM prop.Properties
            JOIN prop.PropertySets ON PropertySets."Set" = Properties."Set"
            WHERE Name = 'ExtSchedulerAllowEventOverlap'
        ) P ON R.Container = P.ObjectId
        WHERE (P.Value IS NULL OR P.Value = 'false') AND (
            (R.Container = NEW.Container AND R.ResourceId = NEW.ResourceId AND R.StartDate < NEW.EndDate AND NEW.StartDate < R.EndDate)
            AND NOT (R.Id = NEW.Id)
        )
    ) THEN
        RAISE EXCEPTION 'Start/End date ranges may not overlap for the same resource.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* 20.xxx SQL scripts */

/*
Created:  2020-05-07
Created by jonesga
Purpose:  Update of Comments field of scheduler per user request
*/
ALTER TABLE extscheduler.Events ALTER COLUMN Comments TYPE VARCHAR(4000);

/*
Created:  2020-05-07
Created by jonesga
Purpose:  Dataset to mimic DateRange from Labkey for SCheduler actionin SQL
*/
SELECT core.fn_dropifexists('DateParts', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extScheduler.dateParts
(
    date TIMESTAMP,
    dateOnly DATE,
    DayOfYear INT,
    DayofMonth INT,
    DayofWeek INT,
    DayName VARCHAR(20),
    WeekofMonth INT,
    WeekofYear INT,
    Month INT,
    year INT
);

INSERT INTO extScheduler.DateParts
    (Date,
    dateonly,
    DayOfYear,
    DayofMonth,
    DayofWeek,
    DayName,
    WeekofMonth,
    WeekofYear,
    Month,
    year)
SELECT
    i.NDate,
    CAST(i.NDate AS DATE) AS dateOnly,
    CAST(EXTRACT(DOY FROM i.NDate) AS INTEGER) AS DayOfYear,
    CAST(EXTRACT(DAY FROM i.NDate) AS INTEGER) AS DayOfMonth,
    CAST(EXTRACT(DOW FROM i.NDate) AS INTEGER) + 1 AS DayOfWeek,
    CAST(EXTRACT(DAY FROM i.NDate) AS VARCHAR(20)) AS DayName,
    (CAST(EXTRACT(DAY FROM i.NDate) AS INTEGER) / 7) AS WeekofMonth,
    CAST(EXTRACT(WEEK FROM i.NDate) AS INTEGER) AS WeekofYear,
    CAST(EXTRACT(MONTH FROM i.NDate) AS INTEGER) AS Month,
    CAST(EXTRACT(YEAR FROM i.NDate) AS INTEGER) AS Year
FROM (SELECT CAST('2020-05-01' AS TIMESTAMP) + (i.value * INTERVAL '1 day') AS NDate FROM ldk.integers i) i
WHERE i.NDate <= '2021-04-20';

-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for 3:30 to 7 PM on Monday and Friday
-- =============================================
SELECT core.fn_dropifexists('extBlockOutEvening', 'extscheduler', 'PROCEDURE', NULL);

CREATE OR REPLACE PROCEDURE extscheduler.extBlockOutEvening(
    _Month INTEGER,
    _ResourceID INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO extscheduler.Events
    (
        ResourceId,
        Name,
        StartDate,
        EndDate,
        UserId,
        Container,
        CreatedBy,
        Created,
        Quantity,
        Comments
    )
    SELECT
        _ResourceID,
        'No Covid-19 Testing',
        c.date + INTERVAL '1530 hours',
        c.date + INTERVAL '19 hours',
        1003,
        '5C3C9FF8-6BCF-1038-930A-7D62F3A605B4',
        1003,
        NOW(),
        1,
        'Insert by ISE'
    FROM extscheduler.dateParts c
    WHERE c.dayofWeek IN (2, 6) AND c.Month = _Month;
END;
$$;

-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for 7 to 8 on Monday and Friday
-- =============================================
SELECT core.fn_dropifexists('extBlockOutMorning', 'extscheduler', 'PROCEDURE', NULL);

CREATE OR REPLACE PROCEDURE extscheduler.extBlockOutMorning(
    _Month INTEGER,
    _ResourceID INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO extscheduler.Events
    (
        ResourceId,
        Name,
        StartDate,
        EndDate,
        UserId,
        Container,
        CreatedBy,
        Created,
        Quantity,
        Comments
    )
    SELECT
        _ResourceID,
        'No Covid-19 Testing',
        c.date + INTERVAL '7 hours',
        c.date + INTERVAL '8 hours',
        1003,
        '5C3C9FF8-6BCF-1038-930A-7D62F3A605B4',
        1003,
        NOW(),
        1,
        'Insert by ISE'
    FROM extscheduler.dateParts c
    WHERE c.dayofWeek IN (2, 6) AND c.Month = _Month;
END;
$$;

-- =============================================
-- Author:		jonesga@ohsu.edu
-- Create date: 2020-05-13
-- Description:	PRocedure to Block out Scheduling for Covid19 testing for all days except Monday and Friday
-- =============================================
SELECT core.fn_dropifexists('extBlockOutDays', 'extscheduler', 'PROCEDURE', NULL);

CREATE OR REPLACE PROCEDURE extscheduler.extBlockOutDays(
    _Month INTEGER,
    _ResourceID INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO extscheduler.Events
    (
        ResourceId,
        Name,
        StartDate,
        EndDate,
        UserId,
        Container,
        CreatedBy,
        Created,
        Quantity,
        Comments
    )
    SELECT
        _ResourceID,
        'No Covid-19 Testing',
        c.date + INTERVAL '7 hours',
        c.date + INTERVAL '19 hours',
        1003,
        '5C3C9FF8-6BCF-1038-930A-7D62F3A605B4',
        1003,
        NOW(),
        1,
        'Insert by ISE'
    FROM extscheduler.dateParts c
    WHERE c.dayofWeek IN (1, 3, 4, 5, 7) AND c.Month = _Month;
END;
$$;

SELECT core.fn_dropifexists('vw_Covid19Research', 'extScheduler', 'VIEW', NULL);

CREATE VIEW extScheduler.vw_Covid19Research AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
       extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
FROM     extscheduler.Events LEFT OUTER JOIN
         core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
         extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
WHERE  (extscheduler.Events.ResourceId = 67);

SELECT core.fn_dropifexists('vw_Covid19DCMSchedule', 'extScheduler', 'VIEW', NULL);

CREATE VIEW extScheduler.vw_Covid19DCMSchedule AS
SELECT extscheduler.Events.Id AS SChedulerID, extscheduler.Events.ResourceId, extscheduler.Resources.Name AS ResourceName, extscheduler.Events.Name, extscheduler.Events.StartDate, extscheduler.Events.UserId,
    extscheduler.Events.CreatedBy, extscheduler.Events.Created, extscheduler.Events.Quantity, core.UsersData.IM AS EmployeeID
    FROM     extscheduler.Events LEFT OUTER JOIN
    core.UsersData ON extscheduler.Events.UserId = core.UsersData.UserId LEFT OUTER JOIN
    extscheduler.Resources ON extscheduler.Events.ResourceId = extscheduler.Resources.Id
    WHERE  (extscheduler.Resources.Name LIKE 'DCM%');

SELECT core.fn_dropifexists('Covid19Testing', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extScheduler.Covid19Testing (
    container ENTITYID NOT NULL,
    entityId ENTITYID NOT NULL,
    lastIndexed TIMESTAMP NULL,
    createdBy INT NULL,
    modified TIMESTAMP NULL,
    modifiedBy INT NULL,
    created TIMESTAMP NULL,
    "Key" SERIAL NOT NULL,
    SchedulerID INT NULL,
    ResourceID INT NULL,
    UserName VARCHAR(4000) NULL,
    UserID INT NULL,
    EmployeeID VARCHAR(4000) NULL,
    ScheduledDate TIMESTAMP NULL,
    ScheduledTime TIMESTAMP NULL,
    "Create" TIMESTAMP NULL,
    SampleDate VARCHAR(4000) NULL,
    CreatedB VARCHAR(4000) NULL,
    ComplianceUpdated BOOLEAN NULL,
    CONSTRAINT covid19testing_pk PRIMARY KEY ("Key")
);

SELECT core.fn_dropifexists('Covid19Testing', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extScheduler.Covid19Testing (
    container ENTITYID NOT NULL,
    entityId ENTITYID NOT NULL,
    lastIndexed TIMESTAMP NULL,
    createdBy INT NULL,
    modified TIMESTAMP NULL,
    modifiedBy INT NULL,
    created TIMESTAMP NULL,
    "Key" SERIAL NOT NULL,
    SchedulerID INT NULL,
    ResourceID INT NULL,
    UserName VARCHAR(4000) NULL,
    UserID INT NULL,
    EmployeeID VARCHAR(4000) NULL,
    ScheduledDate TIMESTAMP NULL,
    ScheduledTime TIMESTAMP NULL,
    "Create" TIMESTAMP NULL,
    SampleDate VARCHAR(4000) NULL,
    CreatedB VARCHAR(4000) NULL,
    ComplianceUpdated BOOLEAN NULL,
    CONSTRAINT covid19testingKey_pk PRIMARY KEY ("Key")
);

SELECT core.fn_dropifexists('TempScheduler', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extscheduler.TempScheduler (
    Searchkey INT GENERATED BY DEFAULT AS IDENTITY (START WITH 100) NOT NULL,
    usernames VARCHAR(500) NULL,
    EventId TEXT NULL,
    StartDate TIMESTAMP NULL,
    created TIMESTAMP NULL
);

SELECT core.fn_dropifexists('TempCoV19Interim', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extscheduler.TempCoV19Interim (
    EventId TEXT NULL,
    UserName VARCHAR(1000) NULL,
    container TEXT NULL,
    notes VARCHAR(100) NULL
);

SELECT core.fn_dropifexists('TempCoV19Interim', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extscheduler.TempCoV19Interim (
    EventId TEXT NULL,
    UserName VARCHAR(1000) NULL,
    container TEXT NULL
);

SELECT core.fn_dropifexists('TempCoV19Final', 'extScheduler', 'TABLE', NULL);

CREATE TABLE extscheduler.TempCoV19Final (
    container UNIQUEIDENTIFIER NOT NULL,
    UserName VARCHAR(4000) NULL,
    UserID INT NULL,
    EventID INT NULL,
    StartDate TIMESTAMP NULL,
    EmployeeID VARCHAR(4000) NULL,
    Created TIMESTAMP NULL
);

/* 21.xxx SQL scripts */

ALTER TABLE extscheduler.Resources ADD Instance VARCHAR(50);

/* 23.xxx SQL scripts */

SELECT core.fn_dropifexists('TempCoV19Final', 'extScheduler', 'TABLE', NULL);
SELECT core.fn_dropifexists('covid19testing', 'extScheduler', 'TABLE', NULL);
SELECT core.fn_dropifexists('tempscheduler', 'extScheduler', 'TABLE', NULL);
SELECT core.fn_dropifexists('TempCoV19Interim', 'extScheduler', 'TABLE', NULL);
SELECT core.fn_dropifexists('vw_Covid19Research', 'extScheduler', 'VIEW', NULL);
SELECT core.fn_dropifexists('vw_covid19dcmschedule', 'extScheduler', 'VIEW', NULL);
SELECT core.fn_dropifexists('vw_Covid19DCMDaily', 'extScheduler', 'VIEW', NULL);
