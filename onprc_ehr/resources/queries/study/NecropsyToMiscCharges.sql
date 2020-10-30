SELECT
b.Id as "NecropsyID",
b.date as "NecropsyDate",
b.procedureid as "Necropsyprocedure",
b.caseno,
b.project as "NecropsyProject",
b.project.investigatorId.lastname as "NecropsyInvestigator",
b.taskid as "NecropsyTaskID",
b.QCstate as "NecropsyStatus",
 r1.Id as "MiscID",
r1.date as "MiscDate",
r1.project as "MiscProject",
r1.chargeId,
r1.quantity,
r1.unitCost,
r1.chargecategory,
r1.QCstate as "MiscStatus",
r1.taskid as "MiscTaskID"


FROM  study.encounters b


Left join (
    Select a.Id, a.date, a.project, a.chargeId, a.quantity, a.unitCost, a.chargecategory, a.QCState, a.taskid
         from  onprc_billing.miscCharges a
         Where a.chargeid.rowid in (4484,4485,4486,4487,4488,4489,5283, 4516,5296,5297,5298)
   group by a.Id, a.date, a.project, a.chargeId, a.quantity, a.unitCost, a.chargecategory, a.QCState, a.taskid

) r1 on (r1.id = b.id )
Where  b.type = 'Necropsy'

