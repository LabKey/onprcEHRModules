/*
 * Copyright (c) 2016-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

SELECT
'[Update order]' AS updatelink,
'[Print view]' AS printviewlink,
p.rowid,
p.requestdate,
p.projectname,
p.protocol,
p.investigator,
p.requestorid,
p.requestor,
p.vendor,
pd.species,
pd.gender As Sex,
pd.strain,
pd.weight,
pd.gestation,
pd.room,
pd.animalsordered,
pd.expectedarrivaldate,
p.confirmationnum,
p.housingconfirmed,
p.orderdate,
pd.sla_DOB,
pd.vendorLocation,
pd.housingInstructions,
pd.receiveddate,
pd.receivedby,
pd.datecancelled,
pd.cancelledby

FROM PublicPurchase p, PublicPurchaseDetails pd
WHERE p.objectid = pd.purchaseid

