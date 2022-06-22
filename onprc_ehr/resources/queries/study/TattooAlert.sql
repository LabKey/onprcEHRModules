Select Id, birth, gender from study.demographics a
Where a.calculated_status = 'Alive'
  And a.id not in (Select id from study.arrival where acquisitiontype = 6) --6= Purchase
  And a.id not in (Select id from study.encounters where procedureid = 760)