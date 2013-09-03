CREATE TABLE onprc_billing.labworkFeeDefinition (
  rowid int identity(1,1),
  servicename varchar(200),
  chargeType int,
  chargeId int,

  active bit default 1,
  objectid ENTITYID,
  createdBy int,
  created datetime,
  modifiedBy int,
  modified datetime,

  CONSTRAINT PK_labworkFeeDefinition PRIMARY KEY (rowId)
);
