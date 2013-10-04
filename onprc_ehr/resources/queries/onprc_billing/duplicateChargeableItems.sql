SELECT
ci.name,
null as itemCode,
count(*) as total

from onprc_billing.chargeableItems ci
where ci.active = true
group by ci.name
having count(*) > 1

UNION ALL

SELECT
null as name,
ci.itemCode,
count(*) as total

from onprc_billing.chargeableItems ci
where ci.active = true and ci.itemCode is not null
group by ci.itemCode
having count(*) > 1