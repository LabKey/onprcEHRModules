--this should be OK since we declare a dependency on EHR, meaning its scripts will run first
UPDATE ehr.qcStateMetadata SET draftData = 1 WHERE QCStateLabel = 'Request: Pending';