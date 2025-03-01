SELECT
    COALESCE(t1.subjectId, t2.marker) as subjectId,
    COALESCE(t1.marker, t2.marker) as marker,
    COALESCE(t1.assaytype, t2.assaytype) as assaytype,

    t1.totalTests as totalTestsCached,
    t1.result as resultCached,
    t1.score as scoreCached,

    t2.totalTests as totalTestsSource,
    t2.result as resultSource,
    t2.score as scoreSource

FROM geneticscore.mhc_data t1
FULL JOIN geneticscore.mhc_data_source t2 ON (t1.subjectId = t2.subjectId AND t1.marker = t2.marker AND t1.assaytype = t2.assaytype)

WHERE
    NOT ISEQUAL(t1.totalTests, t2.totalTests) OR
    NOT ISEQUAL(t1.result, t2.result)