SELECT
    t1.subjectId,
    t1.marker,
    group_concat(distinct (t1.assaytype || ':' || t1.result), chr(10)) as results

FROM geneticscore.mhc_data t1
GROUP BY t1.subjectId, t1.marker
HAVING count(distinct t1.result) > 1