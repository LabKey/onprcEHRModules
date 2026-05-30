/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT c.Id,
c.date,
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
c.objectID as sourceRecord,
c.datefinalized as billingDate
FROM study.clinpathRuns c left outer join Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer')}.lists.Labfee_NoChargeProjects p on c.project.DisplayName  = p.project
where (p.dateDisabled is null and p.project is Null)