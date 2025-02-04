CREATE TABLE onprc_ehr.procedure_default_observations (
 rowid int identity(1,1),
  procedureid  int,
  category varchar(100) Null,
  area varchar(100) Null,
  observation_score varchar(100) Null,
  inflammation varchar(100) Null,
  bruising varchar(100) Null,
  other varchar(100) Null,
  remark varchar(100) Null


  CONSTRAINT PK_procedure_default_observations PRIMARY KEY (rowid)
)

GO

CREATE TABLE onprc_ehr.procedure_default_blood (
   rowid int identity(1,1),
   procedureid  int,
   sampletype varchar(300) Null,
   additionalServices varchar(1000) Null,
   reason varchar(300) Null,
   instructions varchar(2000) Null,
   chargetype varchar(400) Null


  CONSTRAINT PK_procedure_default_blood PRIMARY KEY (rowid)
)

GO