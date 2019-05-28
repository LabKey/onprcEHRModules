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
CREATE TABLE onprc_ehr.investigators (
    rowId int identity(1,1) NOT NULL,
    firstName varchar(100),
    lastName varchar(100),
    position varchar(100),
    address varchar(500),
    city varchar(100),
    state varchar(100),
    country varchar(100),
    zip varchar(100),
    phoneNumber varchar(100),
    investigatorType varchar(100),
    emailAddress varchar(100),
    dateCreated datetime,
    dateDisabled datetime,
    division varchar(100),
    financialAnalyst int,

    createdby userid,
    created datetime,
    modifiedby userid,
    modified datetime,
    CONSTRAINT pk_investigators PRIMARY KEY (rowid)
);