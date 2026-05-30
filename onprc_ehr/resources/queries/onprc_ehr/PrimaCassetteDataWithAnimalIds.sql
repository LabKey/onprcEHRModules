/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
/*
 Added by Kollil April, 2025
 This query will join the cassette data with EHR data. Refer to tkt #11937
 */
Select
    sd.id, -- ONPRC AnimalId
    pc.CassetteAccessionNumber,
    pc.TissueType,
    pc.TissueTypeAbbreviation,
    pc.TissueAlternateIdentifier
From PrimatoPrimeCassetteData pc, study.Demographics sd
Where pc.id = sd.id