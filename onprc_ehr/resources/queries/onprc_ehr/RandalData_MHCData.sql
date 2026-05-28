/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

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
where (active = 'y' and Cast(s.rh as varchar(25)) = Cast(d.id as varchar(25)))