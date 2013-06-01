SELECT
  f.category,
  f.value,
  count(DISTINCT f.Id) as distinctAnimals,
  count(f.Id) as totalRecords

FROM study."Animal Record Flags" f
WHERE f.enddateCoalesced >= curdate()
GROUP BY f.category, f.value