--this should be OK since we declare a dependency on EHR, meaning its scripts will run first
UPDATE ehr.qcStateMetadata SET draftData = true WHERE QCStateLabel = 'Request: Pending';