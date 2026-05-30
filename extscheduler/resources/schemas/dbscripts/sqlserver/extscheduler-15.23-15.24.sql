/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
DROP TABLE extscheduler.users;


CREATE TABLE extscheduler.users
(
  Id INT IDENTITY(1,1) NOT NULL,
  PrimeUserID USERID NOT NULL,
  FirstName VARCHAR(255) NOT NULL,
  LastName Varchar(255) NOT NULL,
  Email VARCHAR(255) NOT NULL,
  Phone VARCHAR(255),
  Department VARCHAR(255),
  Lab_FirstName VARCHAR(255),
  Lab_LastName VARCHAR(255),
  FiscalAuthority_Name VARCHAR(255),
  FiscalAuthority_Phone VARCHAR(255),
  SecurityLevel VARCHAR(255),
  Container ENTITYID NOT NULL,
  CreatedBy USERID,
  Created DATETIME,
  ModifiedBy USERID,
  Modified DATETIME,

  CONSTRAINT PK_users PRIMARY KEY (Id),
  CONSTRAINT FK_users_PrimeUserID FOREIGN KEY (PrimeUserID) REFERENCES core.Usersdata(UserId),
  CONSTRAINT UQ_users_ContainerPrimeUserID UNIQUE (Container, PrimeUserID)
);
