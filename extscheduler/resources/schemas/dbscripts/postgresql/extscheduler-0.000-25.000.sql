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
            JOIN prop.PropertySets ON PropertySets.Set = Properties.Set
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
