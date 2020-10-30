--  Created: 3-24-2017  R.Blasa


SELECT
t.taskid,
t.updateTitle,
t.category,
t.title,
t.formtype,
t.qcstate,
t.assignedto,
t.duedate,
t.requestid,
t.datecompleted,
t.createdby,
t.created,
t.description,
g.procedureid.name as ProcedureName,
g.project.InvestigatorId.lastname as Investigator
FROM ehr.tasks t
 Left join study.encounters g on (t.taskid = g.taskid And g.type = 'Necropsy')

WHERE  ISMEMBEROF(t.assignedto)

