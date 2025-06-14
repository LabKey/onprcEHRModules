/*
 Added by Kollil April, 2025
 This query will extract the cassette data from the ETLed db tables from Prima db. Refer to tkt #11937
 */
SELECT
    an.Identifier as Id,
    --an.AlternateIdentifier as AnimalAlternateIdentifier,
    ctb.SavedIdentifier as CassetteAccessionNumber,
    ctb.AlternateIdentifier as TissueAlternateIdentifier,
    tc.Title as TissueType,
    tc.Abbreviation as TissueTypeAbbreviation
    --cb.Id as CaseId
FROM Prima_CassetteBases as ctb
         join Prima_TissueCollections tc on ctb.TissueCollectionId = tc.Id
         join Prima_CaseBase cb on cb.Id = ctb.CaseBaseId
         Join Prima_Animals an on cb.AnimalId = an.Id
Where ctb.SavedIdentifier NOT LIKE 'IPC%'
  And ctb.SavedIdentifier NOT LIKE '19[0-9][0-9]%'
  And ctb.SavedIdentifier NOT LIKE '20[0-9][0-9]%'