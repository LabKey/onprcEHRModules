-- Query to get active aliases, project and PI details to display in the ART Core Aliases drop down list
-- Created by Kollil: Oct 2021
-- Modified by Kollil: 3/15/22 to show the GL aliases, removed the Project number from the drop down list.
-- The category on the alias table is OHSU GL. There could be other alias that will be used for charges that are not associated with a center project.
-- I hope at some point when this is automated, or when ART core understands they can use the center project for charging.

SELECT alias, alias + ' - ' + COALESCE(investigatorName, 'N/A') as aliasPI
FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases
WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate >= TIMESTAMPADD('SQL_TSI_DAY', -30, now()) ))

-- SELECT
-- a.alias,
-- (Select c.name from Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.ehr.project c where b.project = c.project) + ', ' + a.alias + ' - ' + COALESCE(a.investigatorName, 'N/A') as aliasPI
-- FROM "/onprc/admin/finance/public".onprc_billing_public.aliases a,
--     "/onprc/admin/finance/public".onprc_billing_public.projectAccountHistory b
-- WHERE (a.budgetstartdate IS NOT NULL AND (a.budgetEndDate IS NULL OR a.budgetEndDate >= TIMESTAMPADD('SQL_TSI_DAY', -30, now()) ))
-- AND a.alias = b.account


