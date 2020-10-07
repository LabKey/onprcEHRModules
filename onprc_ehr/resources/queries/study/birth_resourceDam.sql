SELECT b.Id,
b.date,
b.date_type,
b.birth_condition,
b.room,
b.cage,
b.dam,
b.gender,
b.species,
a.project.use_category,
a.project as DammProject

FROM birth b join study.assignment a on b.dam = a.id
where a.project.use_Category not in  ('Research','Aging Resources')