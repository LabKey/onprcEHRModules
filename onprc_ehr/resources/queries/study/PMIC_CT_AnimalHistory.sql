--Created by Kollil
--Modified by Kollil in Aug 2023. Added more filters to the where clause to display the history accurately.

SELECT
    a.Id,
    a.Date,
    a.examNum,
    a.accessionNum,
    a.PMICType,
    a.contrastType,
    a.contrastAmount,
    a.route,
    a.CTACType,
    a.CTScanRange,
    a.phantom,
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
from study.PMIC_CTImagingData a, study.encounters e
Where a.taskid = e.taskid
  and a.id = e.id
  and e.chargetype = 'PMIC'
  and e.type = 'procedure'