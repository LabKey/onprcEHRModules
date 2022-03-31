select * from study.encounters a, study.tissueDistributions
where a.type = 'Tissues'
And a.participantid = b.participantid
And a.date = b.date
And a.requestid = b.requestid