select * from study.encounters a, study.tissueDistributions b,
              onprc_billing.miscCharges e
where a.type = 'Tissues'
  And a.participantid = b.participantid
  And a.participantid = e.Id
  And a.requestid = b.requestid
  and a.requestid = e.requestid