--  Created: 3-30-2017  R.Blasa


SELECT
t.taskid,
t.title,
g.procedureid.name as ProcedureName,
g.project.InvestigatorId.lastname as Investigator,
t.assignedto,
t.duedate,
t.createdby,
t.created,
t.qcstate,
t.formtype


FROM ehr.tasks t
 Left join study.encounters g on (t.taskid = g.taskid And g.type = 'Necropsy')




