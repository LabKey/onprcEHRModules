/*
 * Copyright (c) 2012 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/* onprc_ehr-12.20-12.21.sql */

CREATE SCHEMA onprc_ehr;
GO
CREATE TABLE onprc_ehr.etl_runs
(
    RowId int identity(1,1),
    date datetime,

    Container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowId)
);

/* onprc_ehr-12.21-12.22.sql */

ALTER TABLE onprc_ehr.etl_runs ADD queryname varchar(200);
ALTER TABLE onprc_ehr.etl_runs ADD rowversion varchar(200);