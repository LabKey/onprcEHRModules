/*
 * Copyright (c) 2014 LabKey Corporation
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
CREATE TABLE onprc_ehr.birth_condition (
    rowid int identity(1,1),
    value varchar(200),
    alive bit,
    description varchar(4000),
    container entityid,
    createdby int,
    created datetime,
    modifiedby int,
    modified datetime,

    CONSTRAINT PK_birth_condition PRIMARY KEY (rowid)
);