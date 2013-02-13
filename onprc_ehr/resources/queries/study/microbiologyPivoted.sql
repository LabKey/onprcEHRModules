select

m.id,
m.date,
m.runId,
m.organism.meaning as organism,
group_concat(m.quantity) as quantity

from study."Microbiology Results" m

group by m.id, m.date, m.runId, m.organism.meaning

pivot quantity by organism
