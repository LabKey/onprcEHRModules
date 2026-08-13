/*
 * Copyright (c) 2011 LabKey Corporation
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

CREATE SCHEMA sla;

CREATE TABLE sla.census (
    project INTEGER,
    date TIMESTAMP,
    investigatorid ENTITYID,  -- onprc_ehr.investigators
    room VARCHAR(255),
    species VARCHAR(255),
    cagetype VARCHAR(255),
    cagesize VARCHAR(255),
    counttype INTEGER,
    animalcount INTEGER,
    cagecount INTEGER,
    dlaminventory INTEGER,
    taskid ENTITYID,
    formSort INTEGER,
    QCState INTEGER,
    objectid ENTITYID NOT NULL,

    container ENTITYID NOT NULL,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_census PRIMARY KEY (objectid)
);

CREATE TABLE sla.etl_runs (
    rowid SERIAL,
    date TIMESTAMP,
    queryname varchar(200),
    rowversion varchar(200),

    container ENTITYID NOT NULL,

    CONSTRAINT PK_etl_runs PRIMARY KEY (rowid)
);

CREATE TABLE sla.purchase (
    rowid SERIAL, -- not the PK
    project INTEGER,
    account VARCHAR(255),
    requestorid ENTITYID,
    vendorid ENTITYID,

    hazardslist VARCHAR(255),
    dobrequired INTEGER,
    comments VARCHAR(4000),
    confirmationnum VARCHAR(255),
    darcomments VARCHAR(1000),
    vendorcontact VARCHAR(100),
    housingconfirmed INTEGER,
    iacucconfirmed INTEGER,
    requestdate TIMESTAMP,
    orderdate TIMESTAMP,
    orderedby VARCHAR(100),
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchase PRIMARY KEY (objectid)
);

CREATE TABLE sla.purchaseDetails (
    rowid SERIAL,
    purchaseid ENTITYID,
    species varchar(50),
    age varchar(200),
    weight varchar(200),
    weight_units varchar(100),
    gestation VARCHAR(255),
    gender varchar(50),
    strain VARCHAR(255),
    room varchar(255),
    animalsordered INTEGER,
    animalsreceived INTEGER,
    boxesquantity INTEGER,
    costperanimal VARCHAR(255),
    shippingcost VARCHAR(255),
    totalcost VARCHAR(255),
    housingInstructions VARCHAR(255),
    sla_DOB TIMESTAMP,
    vendorLocation VARCHAR(200),
    requestedarrivaldate TIMESTAMP,
    expectedarrivaldate TIMESTAMP,
    receiveddate TIMESTAMP,
    receivedby VARCHAR(255),
    cancelledby VARCHAR(255),
    datecancelled TIMESTAMP,
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchaseDetails PRIMARY KEY (objectid)
);

CREATE TABLE sla.purchaseDrafts (
    rowid SERIAL,
    owner USERID NOT NULL,
    content text NOT NULL,

    container ENTITYID NOT NULL,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_purchaseDrafts PRIMARY KEY (rowid)
);

CREATE TABLE sla.vendors (
    rowid SERIAL, -- not the PK
    name VARCHAR(255),
    phone1 VARCHAR(15),
    phone2 VARCHAR(15),
    fundingSourceRequired INTEGER,
    comments VARCHAR(255),
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_vendors PRIMARY KEY (objectid)
);

CREATE TABLE sla.requestors (
    rowid SERIAL, -- not the PK
    lastname VARCHAR(255),
    firstname VARCHAR(255),
    initials VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(255),
    userid USERID,
    objectid ENTITYID NOT NULL,

    container ENTITYID,
    createdby USERID,
    created TIMESTAMP,
    modifiedby USERID,
    modified TIMESTAMP,

    CONSTRAINT PK_requestors PRIMARY KEY (objectid)
);

CREATE TABLE sla.allowableAnimals (
    protocol varchar(4000),
    species varchar(200),
    strain varchar(200),
    gender varchar(100),
    age varchar(100),
    allowed integer,

    startdate TIMESTAMP,
    enddate TIMESTAMP,

    objectid ENTITYID NOT NULL,
    container ENTITYID NOT NULL,
    createdby integer NOT NULL,
    created TIMESTAMP NOT NULL,
    modifiedby integer NOT NULL,
    modified TIMESTAMP NOT NULL,

    CONSTRAINT PK_allowableAnimals PRIMARY KEY (objectid)
);

CREATE TABLE sla.species (
    species varchar(200),

    datedisabled TIMESTAMP,
    createdby integer,
    created TIMESTAMP,
    modifiedby integer,
    modified TIMESTAMP,

    CONSTRAINT PK_species PRIMARY KEY (species)
);

INSERT INTO sla.species (species) VALUES ('Rats');
INSERT INTO sla.species (species) VALUES ('Hamsters');
INSERT INTO sla.species (species) VALUES ('Guinea Pigs');
INSERT INTO sla.species (species) VALUES ('Mice');
INSERT INTO sla.species (species) VALUES ('Rabbits');
INSERT INTO sla.species (species) VALUES ('Frogs');
INSERT INTO sla.species (species) VALUES ('Birds');
INSERT INTO sla.species (species) VALUES ('Fish');

CREATE TABLE sla.gender (
    gender varchar(200),

    datedisabled TIMESTAMP,
    createdby integer,
    created TIMESTAMP,
    modifiedby integer,
    modified TIMESTAMP,

    CONSTRAINT PK_gender PRIMARY KEY (gender)
);

INSERT INTO sla.gender (gender) VALUES ('Male or Female');
INSERT INTO sla.gender (gender) VALUES ('Female');
INSERT INTO sla.gender (gender) VALUES ('Male');

-- Note: the primary key is on value, not rowid, matching sla-13.28-13.29.sql. PostgreSQL implicitly
-- adds NOT NULL to the key column, as SQL Server does.
CREATE TABLE sla.Reference_Data (
    rowId SERIAL,
    label varchar(250) DEFAULT NULL,
    value varchar(255),
    columnName varchar(255) NOT NULL,
    sort_order integer NULL,
    endDate TIMESTAMP DEFAULT NULL,

    CONSTRAINT pk_reference PRIMARY KEY (value)
);
