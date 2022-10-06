
SELECT d.rowid,
       d.subjectId,
       d.datatype,
       d.marker,
       d.result,
       d.score,
       d.assaytype,
       d.container,
       d.totalTests

FROM  StudyDetails_RandalData s, Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.MHC_Data.MHC_Data_Unified d
where (Cast(s.rh as varchar(25)) = Cast(d.id as varchar(25)))