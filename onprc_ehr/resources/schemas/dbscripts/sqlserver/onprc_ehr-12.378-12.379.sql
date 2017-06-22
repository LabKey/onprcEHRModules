/*
 * Copyright (c) 2016-2017 LabKey Corporation
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
CREATE TABLE onprc_ehr.NHP_Training(
	 RowId INT IDENTITY(1,1)NOT NULL,
   Id                  varchar(100),
	 date                datetime  NULL,
   training_Ending_Date datetime NULL,
	 training_type        varchar(255) NULL,
	 reason              varchar(255) NULL,
	 qcstate              INTEGER    NULL,
   taskid 	             nvarchar(4000) NULL,
   remark              nvarchar(4000) NULL,
   objectid 	          ENTITYID NOT NULL,
   formSort             SMALLINT  NULL,
   performedby   	      nvarchar(4000) NULL,
	 createdby            int NULL,
	 created              datetime NULL,
	 modifiedby           int NULL,
	 modified             datetime  NULL,
	 Container 	          ENTITYID,
	 training_results     varchar(255) NULL

 CONSTRAINT PK_NHPTrainingObject PRIMARY KEY (objectid)
);