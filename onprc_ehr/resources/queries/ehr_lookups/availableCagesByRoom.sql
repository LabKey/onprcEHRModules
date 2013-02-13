SELECT
c.room,
  count(*) as availableCages

FROM ehr_lookups.availableCages c
WHERE c.isAvailable = true
GROUP BY c.room