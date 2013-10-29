CREATE TABLE onprc_billing.dataAccess (
  rowId int identity(1,1) NOT NULL,
  userid int,
  investigatorId int,
  project int,
  allData bit,

  container entityid NOT NULL,
  createdBy int,
  created datetime,
  modifiedBy int,
  modified datetime,

  CONSTRAINT PK_dataAccess PRIMARY KEY (rowId)
);