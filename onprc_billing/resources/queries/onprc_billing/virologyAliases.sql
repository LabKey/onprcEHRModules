SELECT alias, alias + ' - ' + COALESCE(investigatorName, 'N/A') as aliasPI
FROM "/onprc/admin/finance/public".onprc_billing_public.aliases
--WHERE a.projectStatus in ('Active', 'Partial Setup', 'No Cost Ext', 'Preaward') OR a.alias in ('68119000', '46050050')
WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate > now() )) OR alias in ('68119000', '46050050','46030010', '61247550')
--Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}
--WHERE (budgetstartdate IS NOT NULL AND (budgetEndDate IS NULL OR budgetEndDate > now() ))
--OR alias in (Select alias from Special_Aliases Where category like 'Virology')
