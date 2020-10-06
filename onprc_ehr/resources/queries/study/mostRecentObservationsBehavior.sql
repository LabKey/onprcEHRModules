
--- Created: 8-23-2018  R.Blasa
select a.id,a.date,a.reviewdate,
a.isactive,
a.allproblemcategories,
a.caseHistory,
b.observations
 from study.cases a, mostrecentobservationsforcase b
where a.id = b.id
and a.objectid = b.caseid
and a.category = 'Behavior'
and a.isopen = true