CREATE TABLE onprc_ehr.vet_assignment (
  rowid serial,
  userid int,
  area varchar(100),
  protocol varchar(100),

  container ENTITYID NOT NULL,
  created timestamp,
  createdby int,
  modified timestamp,
  modifiedby int,

  CONSTRAINT PK_vet_assignment PRIMARY KEY (rowid)
);