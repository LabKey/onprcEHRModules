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