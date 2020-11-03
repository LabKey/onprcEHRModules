SELECT
a.ResourceId,
a.Name,
a.StartDate,
a.EndDate,
a.UserId,
a.Alias
FROM Events a
WHERE a.alias NOT IN (Select b.alias FROM Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing_public.aliases b)
--AND a.alias IS NOT NULL