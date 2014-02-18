CREATE TABLE onprc_ehr.vet_assignment (
  rowid int identity(1,1),
  userid int,
  area varchar(100),
  protocol varchar(100),

  container ENTITYID NOT NULL,
  created datetime,
  createdby int,
  modified datetime,
  modifiedby int,

  CONSTRAINT PK_vet_assignment PRIMARY KEY (rowid)
);