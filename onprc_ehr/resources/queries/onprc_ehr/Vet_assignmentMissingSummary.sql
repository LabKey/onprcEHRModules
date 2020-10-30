SELECT m.MissingItem,
Count(m.Item) As TotalMissing
--m.Vet_AssignedItem,
--m.totalNHps
FROM vet_assignmentMissingData m
group by m.missingItem