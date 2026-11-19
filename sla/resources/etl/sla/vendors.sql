/*
 * Copyright (c) 2013-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
Select
SLAVendorName as name,
Phone1 ,
Phone2,
FundingSourceRequired,
Comments,
cast(vl.objectid as varchar(36)) as objectid

From Ref_SLAVendors vl
Where ( vl.ts > ?)
