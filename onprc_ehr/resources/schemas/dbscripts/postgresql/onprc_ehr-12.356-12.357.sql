CREATE TABLE onprc_ehr.housing_transfer_requests (
  Id varchar(100),
  date timestamp,
  room varchar(200),
  cage varchar(100),
  reason varchar(100),
  remark varchar(4000),
  qcstate int,

  requestid entityid,
  objectid entityid NOT NULL,
  container entityid,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  CONSTRAINT PK_housing_transfer_requests PRIMARY KEY (objectid)
);