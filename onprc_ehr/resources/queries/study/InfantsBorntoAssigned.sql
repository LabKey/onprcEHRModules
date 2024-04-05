Select
a.Id,
a.date,
a.dam,
a.sire,
(select group_concat( b.project.name) AS N from  study.assignment b
where  b.qcstate = 18 and b.isActive ='true' And b.participantid = a.dam)  ProjectName,

a.QCState
FROM study.birth a
Where a.dam in (select b.Id from  study.assignment b
where b.project.name not in ('0492-02','0492-03','1063')
and b.qcstate = 18 and b.isActive ='true')

And a.Id.DataSet.demographics.calculated_status.code = 'Alive'
and a.qcstate = 18
and not(a.species in ('rabbit', 'guinea pig'))

UNION

Select
a.Id,
a.date,
a.dam,
a.sire,
(select group_concat( b.project.name) AS N from  study.assignment b
where  b.qcstate = 18 and b.isActive ='true' And b.participantid = a.dam)  ProjectName,

a.QCState
FROM study.birth a
Where a.dam in (select b.Id from  study.assignment b
where b.project.name not in ('0492-02','0492-03','1063')
and b.qcstate = 18 and b.isActive ='true')
And a.Id.DataSet.demographics.calculated_status.code = 'Dead'
and a.qcstate = 18
and not(a.species in ('rabbit', 'guinea pig'))

UNION

Select
a.Id,
a.date,
a.dam,
a.sire,
(select group_concat( b.project.name) AS N from  study.assignment b
where  b.qcstate = 18 and b.isActive ='true' And b.participantid = a.dam)  ProjectName,

a.QCState
FROM study.birth a
Where a.dam in (select b.Id from  study.assignment b
where b.project.name not in ('0492-02','0492-03','1063')
and b.qcstate = 18 and b.isActive ='true')
and a.qcstate = 18
and a.birth_condition = 'Fetus - Prenatal'
and not(a.species in ('rabbit', 'guinea pig'))

