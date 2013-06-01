CREATE TABLE onprc_ehr.tissue_recipients (
  rowId int identity(1,1) NOT NULL,
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

  dateCreated DATETIME,
  dateDisabled DATETIME,

  investigatorId int,

  objectid entityid,
  container entityid,
  createdby userid,
  created DATETIME,
  modifiedby userid,
  modified DATETIME,
  CONSTRAINT pk_tissue_recipients PRIMARY KEY (rowid)
);