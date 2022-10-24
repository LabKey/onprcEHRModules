SELECT
    a.Id,
    a.Date,
    a.examNum,
    a.accessionNum,
    a.PMICType,
    a.SPECTIsotope,
    a.SPECTDoseMCI,
    a.SPECTDoseMBQ,
    a.route,
    a.CTDIvol,
    a.DLP,
    --totalExamDLP,
    a.wetLabUse,
    a.ligandAndComments,
    --imageUploadLink,
    e.taskid,
    e.qcstate,
    a.performedby,
    a.created,
    a.createdBy
from study.PMIC_SPECTImagingData a, study.encounters e
Where a.taskid = e.taskid