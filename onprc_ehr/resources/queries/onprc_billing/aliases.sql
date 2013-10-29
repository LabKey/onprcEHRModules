SELECT
  alias,
  group_concat(distinct g.projectNumber) as projectNumber

FROM onprc_billing.grantProjects g
WHERE g.alias IS NOT NULL
GROUP BY g.alias