SELECT
    a.Id,
    a.Date,
    a.examNum,
    a.accessionNum,
    a.PMICType,
    a.PETRadioisotope,
    a.PETDoseMCI,
    a.PETDoseMBQ,
    a.route,
    a.CTACType,
    a.CTACScanRange,
    a.CTDIvol,
    a.phantom,
    a.DLP,
    --totalExamDLP,
    a.wetLabUse,
    a.ligandAndComments,
    --imageUploadLink,
    e.taskid, -- get the qc state from encounters table
    e.qcstate,
    a.performedby,
    a.created,
    a.createdBy
from study.PMIC_PETImagingData a, study.encounters e
Where a.taskid = e.taskid
