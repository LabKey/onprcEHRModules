--Update to use corredct method to cross container
--jonesga 11/5/2021
SELECT d.rowid,
       d.subjectId,
       d.datatype,
       d.marker,
       d.result,
       d.score,
       d.assaytype,
       d.container,
       d.totalTests
FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('ONPRC_EHR','MHC_COntainer')}.geneticscore.mhc_data d
where (active = 'y' and Cast(s.rh as varchar(25)) = Cast(d.subjectid as varchar(25)))