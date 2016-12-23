SELECT d.id,d.date,
d.score
FROM demographicsMostRecentBCS d
where (d.score Not like '%-%' or   d.score Not like '%,%' or  d.score Not like '%/%')