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