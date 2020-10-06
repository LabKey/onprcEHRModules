SELECT
a.ResourceId,
a.Name,
a.StartDate,
a.EndDate,
a.UserId,
a.Alias
FROM Events a
WHERE a.alias NOT IN (Select b.alias FROM "/onprc/admin/finance/public".onprc_billing_public.aliases b)
--AND a.alias IS NOT NULL