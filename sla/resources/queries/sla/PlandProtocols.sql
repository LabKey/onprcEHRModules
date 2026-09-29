/*
Changed by Kolli - 4/20/2022, Added Linked schema template references
Changed by Kolli - 2/14/2025, Removed the Breeding info from the protocol field. EHR Issue# 11797
*/
SELECT a.project as ProjectID,
       aa.species,
       a.account as Alias,
       y.grantNumber as OGAGrantNumber,
       a.protocol as ParentIACUC,
       a.title as Title,
       a.name as IACUCCode,
       a.startdate as StartDate,
       a.enddate as EndDate,
       i.FirstName,
       i.LastName,
       i.Division,
       p.external_id,

       --Added the breeding info as one field
       --i.LastName + ': ' + a.name + '('+ p.external_id +')' +  ' ' + aa.Breeding_Info + ' - ' + a.title + ' (Species: ' + aa.species + ')' as PIIacuc

       --Removed the Breeding info in the protocol field as we are not storing the information when user selects the item from drop down list. Approved by Kati in Tkt #11797
       i.LastName || ': ' || a.name || '('|| p.external_id ||')' || ' - ' || a.title || ' (Species: ' || aa.species || ')' as PIIacuc
FROM publicehr.project a
         LEFT JOIN publicehr.protocol p ON p.protocol = a.protocol
         LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
         LEFT JOIN ehrsla.allowableAnimals aa ON a.protocol = aa.protocol
         LEFT JOIN financepublic.aliases y ON y.alias = a.account
WHERE
-- filter based on the current date compared with the start and end dates
    (
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate) OR
    (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate) OR
    (now() between aa.StartDate AND aa.EndDate)
    )
  AND
--Check for the project enddate. Added by LK on 1/16/2019
    (now() between a.StartDate AND a.EndDate)
-- and filtered based on dataAccess for the given user
  AND
    (
    (SELECT max(rowid) as expr FROM financepublic.dataAccess da
-- current logged in user is the dataAccess user
     WHERE isMemberOf(da.userid)
-- has access to all data
       AND (da.allData = true
-- has access to the specified investigatorId and the specified project (if applicable)
         OR (da.investigatorId = i.rowId AND (da.project IS NULL OR da.project = a.project)))
    ) IS NOT NULL
    )
