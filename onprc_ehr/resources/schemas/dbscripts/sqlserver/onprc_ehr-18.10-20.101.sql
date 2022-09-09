-- includes content of onprc_ehr-12.395-12.396.sql to onprc_ehr-17.704-17.705.sql from onprc19.1Prod

/****** Object:  StoredProcedure [onprc_ehr].[etl1_eIACUCtoPRIMEProcessing]    Script Date: 2/7/2018 2:01:46 PM ******/


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
