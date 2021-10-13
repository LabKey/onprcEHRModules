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
    [active] [nvarchar](100) NULl)



    CONSTRAINT pk_StudyDetails_RandalData PRIMARY KEY (Id)
    )
    GO