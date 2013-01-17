DROP TABLE onprc_billing.grants ;
GO

CREATE TABLE onprc_billing.grants (
    grantNumber varchar(100),
    investigatorId int,
    title varchar(500),
    startDate datetime,
    endDate datetime,
    fiscalAuthority int,
    fundingAgency varchar(200),
    grantType varchar(200),

    totalDCBudget double precision,
    totalFABudget double precision,
    budgetStartDate datetime,
    budgetEndDate datetime,

    agencyAwardNumber varchar(200),
    comment text,

    createdBy int,
    created datetime,
    modifiedBy int,
    modified datetime,

    CONSTRAINT PK_grants PRIMARY KEY (grantNumber)
);


DROP TABLE onprc_billing.accounts;

CREATE TABLE onprc_billing.grantProjects (
  rowid int identity(1,1),
  projectNumber varchar(200),
  grantNumber varchar(200),
  fundingAgency varchar(200),
  grantType varchar(200),
  agencyAwardNumber varchar(200),
  investigatorId int,
  alias varchar(200),
  projectTitle varchar(4000),
  projectDescription varchar(4000),
  currentYear int,
  totalYears int,
  awardSuffix varchar(200),
  organization varchar(200),

  awardStartDate datetime,
  awardEndDate datetime,
  budgetStartDate datetime,
  budgetEndDate datetime,
  currentDCBudget double precision,
  currentFABudget double precision,
  totalDCBudget double precision,
  totalFABudget double precision,

  spid varchar(100),
  fiscalAuthority int,
  comment text,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created DATETIME,
  modifiedBy USERID,
  modified DATETIME,

  CONSTRAINT PK_grantProjects PRIMARY KEY (rowid)
);


CREATE TABLE onprc_billing.iacucFundingSources (
  rowid int identity(1,1),
  protocol varchar(200),
  grantNumber varchar(200),
  projectNumber varchar(200),

  startdate datetime,
  enddate datetime,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created DATETIME,
  modifiedBy USERID,
  modified DATETIME,

  CONSTRAINT PK_iacucFundingSources PRIMARY KEY (rowid)
);