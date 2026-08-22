CREATE SCHEMA extscheduler;

CREATE TABLE extscheduler.Resources
(
    Id SERIAL NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Color VARCHAR(20),
    Room VARCHAR(255),
    Bldg VARCHAR(255),
    Instance VARCHAR(50),

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
    Name VARCHAR(255),
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NOT NULL,
    UserId USERID NOT NULL,
    Alias VARCHAR(25),
    Quantity INT,
    Comments VARCHAR(4000),

    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created TIMESTAMP,
    ModifiedBy USERID,
    Modified TIMESTAMP,

    CONSTRAINT PK_events PRIMARY KEY (Id),
    CONSTRAINT FK_events_ResourceId FOREIGN KEY (ResourceId) REFERENCES extscheduler.Resources(Id),
    CONSTRAINT CHK_event_DateRangeValid CHECK (StartDate <= EndDate)
);

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

CREATE TRIGGER TR_OverlappingDateRanges
    BEFORE INSERT OR UPDATE ON extscheduler.events
    FOR EACH ROW
    EXECUTE FUNCTION extscheduler.tr_overlappingdateranges();

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
        c.date + INTERVAL '1530 hours', -- TODO: Claude flagged this as a likely bug (also in SQL Server). This is 63.75 days.
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
