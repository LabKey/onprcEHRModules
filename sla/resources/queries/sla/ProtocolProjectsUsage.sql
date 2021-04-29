--SLA usage numbers including Breeding groups data
SELECT
    a.project as ProjectID,
    a.name AS Project,
    p.external_id as eIACUCNum,
    a.title as Title,
    i.LastName || ', ' || i.FirstName AS PIName,
    x.account as Alias,
    y.projectNumber as OGAProjectNumber,
    y.grantNumber as OGAGrantNumber,
    f.lastname || ', ' || f.firstName as FiscalAuthorityName,
    aa.Species,
    aa.Gender,
    aa.Strain,
    aa.Allowed AS NumAllowed,
    calc.NumUsed,
    aa.StartDate,
    aa.EndDate,
    CASE
        WHEN aa.BreedingAllowed = '1' THEN 'Yes'
        ELSE 'No'
        END AS BreedingAllowed,
    aa.Group_Id,
    aa.Group_Name
FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
    LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
    LEFT JOIN onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups aa ON a.protocol = aa.protocol
    LEFT JOIN (select * from onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
    LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account
    LEFT JOIN (
    --Changed by LK on 5/30 to get the accurate numused.
--Ignore the gender when counting the usage if the approval data gender is: "Male or Female". Count both Male and Female usage.
    (SELECT i.protocol,pd.species,sum(animalsreceived) AS NumUsed
    FROM sla.purchasedetails pd, sla.purchase p, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i,
    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups aa1
    Where p.project = i.project AND p.objectid = pd.purchaseid
    AND aa1.protocol = i.protocol AND aa1.species = pd.species AND aa1.gender = 'Male or Female'
    AND animalsreceived IS NOT NULL
    AND  (p.orderdate between aa1.StartDate AND aa1.EndDate) AND aa1.enddate > now()
    GROUP BY i.protocol, pd.species)

    ) AS calc ON a.protocol = calc.protocol
    AND (aa.species = calc.species OR (aa.species IS NULL AND calc.species IS NULL))
    --AND (aa.gender = calc.gender OR (aa.gender IS NULL AND calc.gender IS NULL))
    --AND (aa.strain = calc.strain OR (aa.strain IS NULL AND calc.strain IS NULL))
WHERE
-- filter based on the current date compared with the start and end dates
    (
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate) OR
    (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate) OR
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
  AND (aa.gender = 'Male or Female')
    )
  AND
--Check for the project enddate. Added by LK on 1/16/2019
    (now() between a.StartDate AND a.EndDate)
-- and filtered based on dataAccess for the given user
  AND
    (
    (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da
-- current logged in user is the dataAccess user
    WHERE isMemberOf(da.userid)
-- has access to all data
  AND (da.allData = true
-- has access to the specified investigatorId and the specified project (if applicable)
   OR (da.investigatorId = i.rowId AND (da.project IS NULL OR da.project = a.project)))
    ) IS NOT NULL
    )

UNION ALL

SELECT
    a.project as ProjectID,
    a.name AS Project,
    p.external_id as eIACUCNum,
    a.title as Title,
    i.LastName || ', ' || i.FirstName AS PIName,
    x.account as Alias,
    y.projectNumber as OGAProjectNumber,
    y.grantNumber as OGAGrantNumber,
    f.lastname || ', ' || f.firstName as FiscalAuthorityName,
    aa.Species,
    aa.Gender,
    aa.Strain,
    aa.Allowed AS NumAllowed,
    calc.NumUsed,
    aa.StartDate,
    aa.EndDate,
    CASE
        WHEN aa.BreedingAllowed = '1' THEN 'Yes'
        ELSE 'No'
        END AS BreedingAllowed,
    aa.Group_Id,
    aa.Group_Name

FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
    LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
    LEFT JOIN onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups aa ON a.protocol = aa.protocol
    LEFT JOIN (select * from onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
    LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account
    LEFT JOIN (
    --Changed by LK on 5/30 to get the accurate numused.
-- Count only the usage for the "Male" or "Female" gender
    (SELECT i.protocol,pd.species,pd.gender,sum(animalsreceived) AS NumUsed
    FROM sla.purchasedetails pd, sla.purchase p, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i,
    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups aa1
    Where p.project = i.project AND p.objectid = pd.purchaseid
    AND aa1.protocol = i.protocol AND aa1.species = pd.species AND aa1.gender = pd.gender AND aa1.gender <> 'Male or Female'
    AND animalsreceived IS NOT NULL
    AND  (p.orderdate between aa1.StartDate AND aa1.EndDate) AND aa1.enddate > now()
    GROUP BY i.protocol, pd.species, pd.gender)

    ) AS calc ON a.protocol = calc.protocol
    AND (aa.species = calc.species OR (aa.species IS NULL AND calc.species IS NULL))
    AND (aa.gender = calc.gender OR (aa.gender IS NULL AND calc.gender IS NULL))
    --AND (aa.strain = calc.strain OR (aa.strain IS NULL AND calc.strain IS NULL))
WHERE
-- filter based on the current date compared with the start and end dates
    (
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate) OR
    (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate) OR
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
  AND (aa.gender <> 'Male or Female')
    )
  AND
--Check for the project enddate. Added by LK on 1/16/2019
    (now() between a.StartDate AND a.EndDate)
-- and filtered based on dataAccess for the given user
  AND
    (
    (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da
-- current logged in user is the dataAccess user
    WHERE isMemberOf(da.userid)
-- has access to all data
  AND (da.allData = true
-- has access to the specified investigatorId and the specified project (if applicable)
   OR (da.investigatorId = i.rowId AND (da.project IS NULL OR da.project = a.project)))
    ) IS NOT NULL
    )

/*
-- SELECT
-- a.project as ProjectID,
-- a.name AS Project,
-- p.external_id as eIACUCNum,
-- a.title as Title,
-- i.LastName || ', ' || i.FirstName AS PIName,
-- x.account as Alias,
-- y.projectNumber as OGAProjectNumber,
-- y.grantNumber as OGAGrantNumber,
-- f.lastname || ', ' || f.firstName as FiscalAuthorityName,
-- aa.Species,
-- aa.Gender,
-- aa.Strain,
-- aa.Allowed AS NumAllowed,
-- calc.NumUsed,
-- aa.StartDate,
-- aa.EndDate
-- FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
-- LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
-- LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
-- LEFT JOIN onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
-- LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa ON a.protocol = aa.protocol
-- LEFT JOIN (select * from onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
-- LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account
-- LEFT JOIN (
-- --   SELECT i.protocol,species,gender,sum(animalsreceived) AS NumUsed
-- --   FROM sla.purchasedetails pd, sla.purchase p
-- --   LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i ON p.project = i.project
-- --   WHERE p.objectid = pd.purchaseid AND animalsreceived IS NOT NULL
-- --   GROUP BY i.protocol,species,gender
--
-- --Changed by LK on 5/30 to get the accurate numused.
-- --Ignore the gender when counting the usage if the approval data gender is: "Male or Female". Count both Male and Female usage.
--    (SELECT i.protocol,pd.species,sum(animalsreceived) AS NumUsed
--    FROM sla.purchasedetails pd, sla.purchase p, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i,
--    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa1
--    Where p.project = i.project AND p.objectid = pd.purchaseid
--    AND aa1.protocol = i.protocol AND aa1.species = pd.species AND aa1.gender = 'Male or Female'
--    AND animalsreceived IS NOT NULL
--    AND  (p.orderdate between aa1.StartDate AND aa1.EndDate) AND aa1.enddate > now()
--    GROUP BY i.protocol, pd.species)
--
-- ) AS calc ON a.protocol = calc.protocol
--         AND (aa.species = calc.species OR (aa.species IS NULL AND calc.species IS NULL))
--         --AND (aa.gender = calc.gender OR (aa.gender IS NULL AND calc.gender IS NULL))
--         --AND (aa.strain = calc.strain OR (aa.strain IS NULL AND calc.strain IS NULL))
-- WHERE
--   -- filter based on the current date compared with the start and end dates
--   (
--     (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate) OR
--     (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate) OR
--     (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
--     AND (aa.gender = 'Male or Female')
--   )
--   AND
--   --Check for the project enddate. Added by LK on 1/16/2019
--   (now() between a.StartDate AND a.EndDate)
--   -- and filtered based on dataAccess for the given user
--   AND
--    (
--     (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da
--       -- current logged in user is the dataAccess user
--       WHERE isMemberOf(da.userid)
--       -- has access to all data
--       AND (da.allData = true
--       -- has access to the specified investigatorId and the specified project (if applicable)
--         OR (da.investigatorId = i.rowId AND (da.project IS NULL OR da.project = a.project)))
--     ) IS NOT NULL
--   )
--
-- UNION ALL
--
-- SELECT
-- a.project as ProjectID,
-- a.name AS Project,
-- p.external_id as eIACUCNum,
-- a.title as Title,
-- i.LastName || ', ' || i.FirstName AS PIName,
-- x.account as Alias,
-- y.projectNumber as OGAProjectNumber,
-- y.grantNumber as OGAGrantNumber,
-- f.lastname || ', ' || f.firstName as FiscalAuthorityName,
-- aa.Species,
-- aa.Gender,
-- aa.Strain,
-- aa.Allowed AS NumAllowed,
-- calc.NumUsed,
-- aa.StartDate,
-- aa.EndDate
-- FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
-- LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
-- LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
-- LEFT JOIN onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
-- LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa ON a.protocol = aa.protocol
-- LEFT JOIN (select * from onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
-- LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account
-- LEFT JOIN (
-- --   SELECT i.protocol,species,gender,sum(animalsreceived) AS NumUsed
-- --   FROM sla.purchasedetails pd, sla.purchase p
-- --   LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i ON p.project = i.project
-- --   WHERE p.objectid = pd.purchaseid AND animalsreceived IS NOT NULL
-- --   GROUP BY i.protocol,species,gender
--
-- --Changed by LK on 5/30 to get the accurate numused.
-- -- Count only the usage for the "Male" or "Female" gender
--    (SELECT i.protocol,pd.species,pd.gender,sum(animalsreceived) AS NumUsed
--    FROM sla.purchasedetails pd, sla.purchase p, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project i,
--    Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa1
--    Where p.project = i.project AND p.objectid = pd.purchaseid
--    AND aa1.protocol = i.protocol AND aa1.species = pd.species AND aa1.gender = pd.gender AND aa1.gender <> 'Male or Female'
--    AND animalsreceived IS NOT NULL
--    AND  (p.orderdate between aa1.StartDate AND aa1.EndDate) AND aa1.enddate > now()
--    GROUP BY i.protocol, pd.species, pd.gender)
--
-- ) AS calc ON a.protocol = calc.protocol
--         AND (aa.species = calc.species OR (aa.species IS NULL AND calc.species IS NULL))
--         AND (aa.gender = calc.gender OR (aa.gender IS NULL AND calc.gender IS NULL))
--         --AND (aa.strain = calc.strain OR (aa.strain IS NULL AND calc.strain IS NULL))
-- WHERE
--   -- filter based on the current date compared with the start and end dates
--   (
--     (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate) OR
--     (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate) OR
--     (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
--     AND (aa.gender <> 'Male or Female')
--   )
--   AND
--   --Check for the project enddate. Added by LK on 1/16/2019
--   (now() between a.StartDate AND a.EndDate)
--   -- and filtered based on dataAccess for the given user
--   AND
--    (
--     (SELECT max(rowid) as expr FROM onprc_billing.dataAccess da
--       -- current logged in user is the dataAccess user
--       WHERE isMemberOf(da.userid)
--       -- has access to all data
--       AND (da.allData = true
--       -- has access to the specified investigatorId and the specified project (if applicable)
--         OR (da.investigatorId = i.rowId AND (da.project IS NULL OR da.project = a.project)))
--     ) IS NOT NULL
--   )