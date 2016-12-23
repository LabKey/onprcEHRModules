CREATE TABLE onprc_ehr.encounter_summaries_remarks (

  id varchar(100),
  date datetime,
  parentid entityid,
  schemaName varchar(100),
  queryName varchar(100),
  remark text,

  objectid varchar(60) NOT NULL,
  container entityid NOT NULL,
  createdby smallint,
  created datetime,
  modifiedby smallint,
  modified datetime,
  taskid  entityid,
  category varchar(100),
  formsort integer

  constraint pk_encounter_summaries_remarks PRIMARY KEY (objectid)
);
