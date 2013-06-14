SELECT
  b1.Id,
  h1.room,
  h1.cage,
  group_concat(DISTINCT h1.Id) as potentialDams,
  min(b1.minDate) as minDate,
  min(b1.maxDate) as maxDate

FROM (

SELECT
  b.Id,
  b.potentialDam,
  b.birth,
  timestampadd('SQL_TSI_DAY', -180, b.birth) as minDate,
  timestampadd('SQL_TSI_DAY', -155, b.birth) as maxDate

FROM study.potentialDams b

) b1

--find all housing records for these females overlapping the conception window
JOIN study.housing h1 ON (
  h1.Id = b1.potentialDam AND
  h1.date <= b1.maxDate AND 
  h1.enddateTimeCoalesced >= b1.minDate
)

GROUP BY b1.Id, h1.room, h1.cage