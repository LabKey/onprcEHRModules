<<<<<<< HEAD
--Update to use corredct method to cross container
--jonesga 11/5/2021
=======

>>>>>>> origin/release21.7-SNAPSHOT
SELECT d.rowid,
       d.subjectId,
       d.datatype,
       d.marker,
       d.result,
       d.score,
       d.assaytype,
       d.container,
       d.totalTests
<<<<<<< HEAD
FROM  StudyDetails_RandalData s, "/ONPRC/Core Facilities/Genetics Core/MHC_Typing".geneticscore.mhc_data d
=======

FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('ONPRC_EHR','MHC_Container')}.geneticscore.mhc_data d
>>>>>>> origin/release21.7-SNAPSHOT
where (active = 'y' and Cast(s.rh as varchar(25)) = Cast(d.subjectid as varchar(25)))