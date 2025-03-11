SELECT
    a.subjectId,
    a.readsetSubjectId,
    a.analysisId,
    a.folder

FROM geneticscore.discordantSubjectIds a
GROUP BY a.subjectId, a.readsetSubjectId, a.analysisId, a.folder
