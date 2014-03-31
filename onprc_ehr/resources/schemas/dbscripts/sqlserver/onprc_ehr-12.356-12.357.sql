CREATE TABLE onprc_ehr.housing_transfer_requests (
  Id varchar(100),
  date datetime,
  room varchar(200),
  cage varchar(100),
  reason varchar(100),
  remark varchar(4000),
  qcstate int,

  requestid entityid,
  objectid entityid NOT NULL,
  container entityid,
  created datetime,
  createdby int,
  modified datetime,
  modifiedby int,

  CONSTRAINT PK_housing_transfer_requests PRIMARY KEY (objectid)
);