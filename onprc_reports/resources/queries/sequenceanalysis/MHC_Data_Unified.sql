/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
 SELECT

     t.Id,
     t.allele,
     t.shortName,
     t.totalTests,
     CASE WHEN numResults > 1 THEN 'DISCORDANT' ELSE t.result END as result,
     t.type,
     t.libraryTypes

 FROM (SELECT t.subjectId                          as Id,
              t.marker                             as allele,
              null                                 as shortName,
              sum(t.totalTests)                    as totalTests,
              GROUP_CONCAT(distinct t.result)      as result,
              count(DISTINCT t.result) as numResults,
              GROUP_CONCAT(distinct t.assaytype)   as type,
              GROUP_CONCAT(distinct t.libraryType) as libraryTypes

       FROM geneticscore.mhc_data t
       GROUP BY t.subjectid, t.marker
) t