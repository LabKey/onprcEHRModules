SELECT
    a.Id,
    a.Date,
    a.examNum,
    a.accessionNum,
    a.PMICType,
    a.DEXAProcedure,
    a.animalPosition,
    a.remark,
    e.taskid,
    e.qcstate,
    a.performedby,
    a.created,
    a.createdBy
from study.PMIC_DEXAImagingData a, study.encounters e
Where a.taskid = e.taskid
  and a.id = e.id
  and e.chargetype = 'PMIC'
  and e.type = 'procedure'