/*
 * Copyright (c) 2024-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
    a.subjectId,
    a.readsetSubjectId,
    a.analysisId,
    a.folder

FROM geneticscore.discordantSubjectIds a
GROUP BY a.subjectId, a.readsetSubjectId, a.analysisId, a.folder
