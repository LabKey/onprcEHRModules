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