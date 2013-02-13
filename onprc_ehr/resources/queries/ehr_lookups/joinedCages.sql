SELECT
p.room,
p.effectiveCage,
group_concat(p.cage, ',') as cages


FROM ehr_lookups.pairedCages p

GROUP BY p.room, p.effectiveCage