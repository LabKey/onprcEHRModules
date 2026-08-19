Select
c.id,
c.observation as score,
c.date,
c.created
From study.clinical_Observations c

RIGHT  JOIN
         (Select
         a.id,
         MAX(CAST(a.date AS DATE)) as MaxDate
        From study.clinical_Observations a
         Where LOWER(a.category) = LOWER('bcs')
         And a.date > TIMESTAMPADD('SQL_TSI_MONTH', -18, Now())
         and a.observation is not null
         --And a.id in ('30661', '16609')
         Group by a.id   -- , a.date
         ) As d

ON c.id = d.id And CAST(c.date AS DATE) = d.MaxDate
Where  c.category = 'bcs' and NOT (LOWER(LEFT(c.id,1)) BETWEEN 'a' AND 'z')
