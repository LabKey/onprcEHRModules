SELECT c.Id,
       c.DATE,
       c.project,
       c.servicerequested,
       c.chargetype,
       c.sampletype,
       c.tissue,
       c.collectionMethod,
       c.method,
       c.remark,
       c.type,
       c.instructions,
       c.units,
       c.taskid,
       c.performedby,
       c.requestid,
       c.history,
       c.isAssignedAtTime,
       c.isAssignedToProtocolAtTime,
       c.enteredSinceVetReview,
       c.QCState,
       c.objectID AS sourceRecord,
       c.datefinalized AS billingDate
FROM Site.{substitutePath moduleProperty('EHR', 'EHRStudyContainer') }.study.clinpathRuns c
LEFT OUTER JOIN Site.{substitutePath moduleProperty('ONPRC_Billing', 'BillingContainer') }.lists.Labfee_NoChargeProjects p ON c.project.DisplayName = p.project
WHERE (
    p.dateDisabled IS NULL
    AND p.project IS NULL
    )