SELECT
    a.Id,
    a.Date,
    a.examNum,
    a.accessionNum,
    a.PMICType,
    a.CTDIvol,
    a.DLP,
    --totalExamDLP,
    a.wetLabUse,
    a.remark,
    --imageUploadLink,
    e.taskid,
    e.qcstate,
    a.performedby,
    a.created,
    a.createdBy
from study.PMIC_AngioImagingData a, study.encounters e
Where a.taskid = e.taskid
  and a.id = e.id
  and e.chargetype = 'PMIC'
  and e.type = 'procedure'