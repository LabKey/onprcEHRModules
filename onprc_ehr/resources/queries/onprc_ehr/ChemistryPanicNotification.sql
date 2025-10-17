select a.Id,
       a.date,
       a.servicerequested,
       b.testid,
       b.qualResult,
       a.vet,
       a.created,
       b.objectid

from study.ClinpathRuns a, study.chemistryResults b
Where  a.objectid = b.runid
  And a.type = 'biochemistry'
  And b.qualresult like '%panic%'
  And a.qcstate = 18
  And b.qcstate = 18