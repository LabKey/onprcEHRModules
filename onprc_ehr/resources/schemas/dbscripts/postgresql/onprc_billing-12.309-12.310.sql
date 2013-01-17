DROP TABLE onprc_billing.grants ;

CREATE TABLE onprc_billing.grants (
    grantNumber varchar(100),
    investigatorId int,
    title varchar(500),
    startDate timestamp,
    endDate timestamp,
    fiscalAuthority int,
    fundingAgency varchar(200),
    grantType varchar(200),

    totalDCBudget double precision,
    totalFABudget double precision,
    budgetStartDate timestamp,
    budgetEndDate timestamp,

    agencyAwardNumber varchar(200),
    comment text,

    createdBy int,
    created timestamp,
    modifiedBy int,
    modified timestamp,

    CONSTRAINT PK_grants PRIMARY KEY (grantNumber)
);


DROP TABLE onprc_billing.accounts;

CREATE TABLE onprc_billing.grantProjects (
  rowid serial,
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

  awardStartDate timestamp,
  awardEndDate timestamp,
  budgetStartDate timestamp,
  budgetEndDate timestamp,
  currentDCBudget double precision,
  currentFABudget double precision,
  totalDCBudget double precision,
  totalFABudget double precision,

  spid varchar(100),
  fiscalAuthority int,
  comment text,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created timestamp,
  modifiedBy USERID,
  modified timestamp,

  CONSTRAINT PK_grantProjects PRIMARY KEY (rowid)
);

CREATE TABLE onprc_billing.iacucFundingSources (
  rowid serial,
  protocol varchar(200),
  grantNumber varchar(200),
  projectNumber varchar(200),

  startdate timestamp,
  enddate timestamp,

  container ENTITYID NOT NULL,
  createdBy USERID,
  created timestamp,
  modifiedBy USERID,
  modified timestamp,

  CONSTRAINT PK_iacucFundingSources PRIMARY KEY (rowid)
);