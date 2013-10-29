CREATE TABLE onprc_billing.dataAccess (
  rowId serial NOT NULL,
  userid int,
  investigatorId int,
  project int,
  allData bool,

  container entityid NOT NULL,
  createdBy int,
  created timestamp,
  modifiedBy int,
  modified timestamp,

  CONSTRAINT PK_dataAccess PRIMARY KEY (rowId)
);