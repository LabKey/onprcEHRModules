/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE TABLE sla.species (
    species varchar (200),

    datedisabled datetime,
    createdby integer,
    created datetime,
    modifiedby integer,
    modified datetime,

    CONSTRAINT PK_species PRIMARY KEY (species)
);
GO
INSERT INTO sla.species (species) values ('Rats');
INSERT INTO sla.species (species) values ('Hamsters');
INSERT INTO sla.species (species) values ('Guinea Pigs');
INSERT INTO sla.species (species) values ('Mice');
INSERT INTO sla.species (species) values ('Rabbits');
INSERT INTO sla.species (species) values ('Frogs');
INSERT INTO sla.species (species) values ('Birds');
INSERT INTO sla.species (species) values ('Fish');


CREATE TABLE sla.gender (
    gender varchar (200),

    datedisabled datetime,
    createdby integer,
    created datetime,
    modifiedby integer,
    modified datetime,

    CONSTRAINT PK_gender PRIMARY KEY (gender)
);
GO
INSERT INTO sla.gender (gender) values ('Male or Female');
INSERT INTO sla.gender (gender) values ('Female');
INSERT INTO sla.gender (gender) values ('Male');