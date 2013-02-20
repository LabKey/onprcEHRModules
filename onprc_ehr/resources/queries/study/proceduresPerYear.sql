SELECT
c.Id,
CAST('01-01-' || cast(year(c.date) as varchar) as date) as date,
CAST('12-31-' || cast(year(c.date) as varchar) as date) as enddate,
year(c.date) as year,
c.procedureid,
count(*) as total

FROM study."Clinical Encounters" c
WHERE c.procedureid IS NOT NULL
GROUP BY c.Id, c.procedureid, year(c.date)