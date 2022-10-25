
SELECT d.subjectId,
d.marker,
d.assaytype,
d.totalTests,
d.score


FROM  StudyDetails_RandalData s, MHC_Data.mhc_data d
where (Cast(s.rh as varchar(25)) = Cast(d.subjectid as varchar(25)))