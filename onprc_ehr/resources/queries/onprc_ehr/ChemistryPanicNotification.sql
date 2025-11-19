select a.Id,
       a.date,
       a.servicerequested,
       b.testid,
       b.qualresult,
       a.vet,
       a.created,
       a.objectid,
       a.taskid,


from study.ClinpathRuns a, study.chemistryResults b
Where  a.objectid = b.runid
  And a.type = 'biochemistry'
  And b.qualresult like '%panic%'
  And a.qcstate = 18
  And b.qcstate = 18