/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
CREATE TABLE onprc_ehr.snomed_counter
(
    subset		nvarchar(255) NOT NULL,
    count		integer NOT NULL,
    prefix		nvarchar(10) NOT NULL,
    container   entityid,
    createdby   userid,
    created     DATETIME,
    modifiedby  userid,
    modified    DATETIME,

    CONSTRAINT pk_snomed_counter PRIMARY KEY (subset),
    CONSTRAINT fk_onprc_snomed_counter_container FOREIGN KEY (container) REFERENCES core.Containers (EntityId)
)