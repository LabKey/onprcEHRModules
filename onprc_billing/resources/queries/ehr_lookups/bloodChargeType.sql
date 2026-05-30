/*
 * Copyright (c) 2014-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT
c.chargetype as value

FROM onprc_billing_public.chargeUnits c
WHERE c.shownInBlood = true