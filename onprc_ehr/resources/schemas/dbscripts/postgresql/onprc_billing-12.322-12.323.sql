CREATE TABLE onprc_billing.labworkFeeDefinition (
  rowid serial,
  servicename varchar(200),
  chargeType int,
  chargeId int,

  active bool default true,
  objectid ENTITYID,
  createdBy int,
  created timestamp,
  modifiedBy int,
  modified timestamp,

  CONSTRAINT PK_labworkFeeDefinition PRIMARY KEY (rowId)
);
