--Update to use corredct method to cross container
--jonesga 10/28/2021
SELECT d.rowid,
       d.subjectId,
       d.datatype,
       d.marker,
       d.result,
       d.score,
       d.assaytype,
       d.container,
       d.totalTests
FROM  StudyDetails_RandalData s, "/ONPRC/Core Facilities/Genetics Core/MHC_Typing".geneticscore.mhc_data d
where (active = 'y' and Cast(s.rh as varchar(25)) = Cast(d.subjectid as varchar(25)))