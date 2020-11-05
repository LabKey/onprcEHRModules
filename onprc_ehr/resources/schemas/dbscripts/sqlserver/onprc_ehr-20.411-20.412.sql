/****** Object:  Table [onprc_ehr].[PotentialSire_source]    Script Date: 4/121/20202 7:00:04 AM ******/
/****** Object:  Table [onprc_ehr].[PotentialDam_source]    Script Date: 4/121/20202 7:00:04 AM ******/
/****** Object:  Table [onprc_ehr].[PotentialParents_source]    Script Date: 4/121/20202 7:00:04 AM ******/

DROP TABLE IF EXISTS [onprc_ehr].[potentialDam_Source]
GO

DROP TABLE IF EXISTS [onprc_ehr].[potentialsire_Source]
GO

DROP TABLE IF EXISTS [onprc_ehr].[potentialParents_Source]
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