/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
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