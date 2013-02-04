select

a.id,
a.date,
a.runId,
a.tissue,
a.microbe.meaning as microbode,
a.antibiotic.meaning as antibiotic,
group_concat(a.resistant) as resistant

from study."Antibiotic Sensitivity" a

group by a.id, a.date, a.runId, a.tissue, a.microbe.meaning, a.antibiotic.meaning

pivot resistant by antibiotic
