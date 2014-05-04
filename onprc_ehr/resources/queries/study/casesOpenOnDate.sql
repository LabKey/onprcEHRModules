PARAMETERS(Date TIMESTAMP)

SELECT
c.Id,
c.date,
c.reviewdate,
c.enddate,
c.category,
c.allProblemCategories,
c.remark,
c.performedby

FROM study.cases c

WHERE

c.dateOnly <= Date
AND (c.enddate IS NULL OR CAST(c.enddate AS DATE) >= Date)
AND (c.reviewdate IS NULL OR CAST(c.reviewdate AS DATE) <= Date)