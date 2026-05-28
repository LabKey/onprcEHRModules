/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
SELECT id,
    date,
    gestation_days,
    ExpectedDelivery,
    TIMESTAMPADD('SQL_TSI_DAY',30, ExpectedDelivery)  as thirty_days_pastGestation_date
FROM pregnancyGestation
--Where gestation_days is not null