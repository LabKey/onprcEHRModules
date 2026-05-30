/*
 * Copyright (c) 2022-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'aliases', 'onprc_billing', 'COLUMN', 'OriginatingAgencyAwardNum';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'ORIGINATING_AGENCY_AWARD_NUM';
GO
ALTER TABLE onprc_billing.aliases ADD [OriginatingAgencyAwardNum] VarChar(255) Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [ORIGINATING_AGENCY_AWARD_NUM] VarChar(255) Null;