/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
'[Review order]' AS reviewlink,
'[Print view]' AS printviewlink,
p.rowid,
p.projectname,
p.protocol,
p.investigator,
p.requestorid,
p.requestor,
p.vendor,
pd.species,
pd.gender as Sex,
pd.strain,
pd.weight,
pd.gestation,
pd.room,
p.requestdate,
pd.expectedarrivaldate,
pd.housingInstructions,
p.confirmationnum,
p.housingconfirmed,
p.orderdate,
pd.sla_DOB,
pd.vendorLocation,
pd.receiveddate,
pd.receivedby,
pd.datecancelled,
pd.cancelledby

FROM PublicPurchase p, PublicPurchaseDetails pd
WHERE p.objectid = pd.purchaseid

