--SLA usage numbers including Breeding groups data extracted from eIACUC data
SELECT
    --a.project As ProjectID,
    a.name As Project,
    p.external_id As IACUCProtocol,
--     aa.eIACUC_protocol_name as eIACUCNum,
    a.title As Title,
    i.LastName || ', ' || i.FirstName As PIName,
--     x.account As Alias,
--     y.projectNumber As OGAProjectNumber,
--     y.grantNumber As OGAGrantNumber,
--     f.lastname || ', ' || f.firstName As FiscalAuthorityName,
    aa.Species,
    aa.Gender,
    aa.Strain,
    aa.Allowed As NumAllowed,
    aa.StartDate,
    aa.EndDate,
    (Select Breeding from (Select protocol, species, gender, allowed, GROUP_CONCAT(Breeding_Info, chr(10)) as Breeding
                           From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups Group by protocol, species, gender, allowed) br
    Where aa.protocol = br.protocol And aa.Species = br.species And aa.Gender = br.Gender And aa.Allowed = br.allowed) as Breeding_Info

FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_ehr.investigators i ON i.rowId = a.investigatorId
    LEFT JOIN Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa ON a.protocol = aa.protocol
    LEFT JOIN (select * from Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
    LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account
    WHERE ( -- filter based on the current date compared with the start and end dates
        (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate)
        OR (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate)
        OR (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
        AND (aa.gender = 'Male or Female') -- This gets only the Gender type: "Male or Female". The other part of the union selects the other gender types: Male, Female and etc
    )
    AND --Check for the project enddate. Added by LK on 1/16/2019
    (now() between a.StartDate AND a.EndDate)

UNION ALL -- This section gets the gender types: Male, Female an etc

SELECT
    --a.project as ProjectID,
    a.name AS Project,
    p.external_id as IACUCProtocol,
--     aa.eIACUC_protocol_name as eIACUCNum,
    a.title as Title,
    i.LastName || ', ' || i.FirstName AS PIName,
--     x.account as Alias,
--     y.projectNumber as OGAProjectNumber,
--     y.grantNumber as OGAGrantNumber,
--     f.lastname || ', ' || f.firstName as FiscalAuthorityName,
    aa.Species,
    aa.Gender,
    aa.Strain,
    aa.Allowed AS NumAllowed,
    aa.StartDate,
    aa.EndDate,
    (Select Breeding from (Select protocol, species, gender, allowed, GROUP_CONCAT(Breeding_Info, chr(10)) as Breeding
                           From Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals_BreedingGroups Group by protocol, species, gender, allowed) br
     Where aa.protocol = br.protocol And aa.Species = br.species And aa.Gender = br.Gender And aa.Allowed = br.allowed) as Breeding_Info

FROM Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project a
LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.protocol p ON p.protocol = a.protocol
    LEFT JOIN onprc_ehr.investigators i ON i.rowId = a.investigatorId
    LEFT JOIN onprc_billing.fiscalAuthorities f ON f.rowid = i.financialanalyst
    LEFT JOIN Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.sla.allowableAnimals aa ON a.protocol = aa.protocol
    LEFT JOIN (select * from Site.{substitutePath moduleProperty('onprc_billing','BillingContainer')}.onprc_billing.projectAccountHistory z where (z.StartDate IS NOT NULL AND z.EndDate IS NOT NULL AND now() between z.StartDate AND z.EndDate)) x ON a.project = x.project
    LEFT JOIN Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases y ON y.alias = x.account

WHERE (-- filter based on the current date compared with the start and end dates
    (aa.StartDate IS NOT NULL AND aa.EndDate IS NULL AND now() > aa.StartDate)
    OR (aa.StartDate IS NULL AND aa.EndDate IS NOT NULL AND now() < aa.EndDate)
    OR (aa.StartDate IS NOT NULL AND aa.EndDate IS NOT NULL AND now() between aa.StartDate AND aa.EndDate)
    AND (aa.gender <> 'Male or Female')
    )
  AND --Check for the project enddate. Added by LK on 1/16/2019
    (now() between a.StartDate AND a.EndDate)

