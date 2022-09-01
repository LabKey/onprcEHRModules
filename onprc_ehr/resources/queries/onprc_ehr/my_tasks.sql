--  Created: 3-24-2017  R.Blasa


SELECT
    t.taskid,
    t.rowid,
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
    (Select s.name from ehr_lookups.procedures s where s.rowid = g.procedureid) as ProcedureName,
    (Select group_concat(DISTINCT j.lastname, chr(10)) from onprc_ehr.investigators j, ehr.project x where j.rowid = x.investigatorId and x.project = g.project ) as Investigator
FROM ehr.tasks t
         Left join study.encounters g on (t.taskid = g.taskid And g.type = 'Necropsy')

WHERE  ISMEMBEROF(t.assignedto)

