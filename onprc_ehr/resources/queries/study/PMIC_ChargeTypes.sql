/*
 * Copyright (c) 2021-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT chargetype
From Site.{substitutePath moduleProperty('ONPRC_Billing','BillingContainer_Public')}.onprc_billing.chargeUnits
Where servicecenter is null or servicecenter like 'PMIC'
