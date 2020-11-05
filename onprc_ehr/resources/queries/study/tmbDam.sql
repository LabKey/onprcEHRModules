--Update 3/11/2019 Added to Test

SELECT a.Id,
a.id.demographics.gender,
a.project,
a.date,
a.projectedRelease,
a.enddate

FROM assignment a where a.project = 559 and enddate is null