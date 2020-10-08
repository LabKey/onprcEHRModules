SELECT alias, alias + ' - ' + COALESCE(investigatorName, 'N/A') as aliasPI
FROM "/onprc/admin/finance/public".onprc_billing_public.aliases
--WHERE a.projectStatus in ('Active', 'Partial Setup', 'No Cost Ext', 'Preaward') OR a.alias in ('68119000', '46050050')
--WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate > now() )) OR alias in ('68119000', '46050050','46030010', '61247550')
--Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}
--WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate >= now() ))
-- including the aliases that expired 30 days ago from today's date. This provision is given to the PIs to enter the previous month charges. By Kolli on 7/6/19
WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate >= TIMESTAMPADD('SQL_TSI_DAY', -30, now()) ))
OR alias in (Select alias from lists.Special_Aliases Where category like 'Virology')
