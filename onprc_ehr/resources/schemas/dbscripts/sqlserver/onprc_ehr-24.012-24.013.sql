/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE TABLE onprc_ehr.pairing_observation_types (
                 rowid [int] IDENTITY(100,1) NOT NULL,
                 value nvarchar(200),
                 category nvarchar(200),
                 editorconfig NVARCHAR(MAX),
                 schemaname nvarchar(200),
                 queryname nvarchar(200),
                 valuecolumn nvarchar(200),
                 Created datetime,
                 CreatedBy USERID,
                 Modified datetime,
                 ModifiedBy USERID,
                 Container	entityId NOT NULL,

                 CONSTRAINT PK_ONPRC_EHR_PAIRING_OBSERVATION_TYPES PRIMARY KEY (rowid),

);
GO
