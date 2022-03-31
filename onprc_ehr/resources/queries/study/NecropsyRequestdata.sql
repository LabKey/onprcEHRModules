select * from study.encounters a, study.tissueDistributions,
              Site.{substitutePath moduleProperty('EHR','EHRStudyContainer')}.onprc_billing.miscCharges e
where a.type = 'Tissues'
And a.participantid = b.participantid
And a.participantid = e.participantid
And a.requestid = b.requestid
and a.requestid = e.requestid