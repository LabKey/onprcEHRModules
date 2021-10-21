SELECT d.rowid,
       d.subjectId,
       d.datatype,
       d.marker,
       d.result,
       d.score,
       d.assaytype,
       d.container,
       d.totalTests
 FROM  StudyDetails_RandalData s, "/ONPRC/EHR".study.mhcdata d
    where (active = 'y' and s.rh = d.id)