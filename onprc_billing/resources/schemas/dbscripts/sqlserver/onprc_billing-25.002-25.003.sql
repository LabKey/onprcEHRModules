/*
 * Copyright (c) 2025-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_START_DATE';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'OGA_AWARD_END_DATE';
GO
EXEC core.fn_dropifexists 'ogaSynch', 'onprc_billing', 'COLUMN', 'IndirectRate';
GO
ALTER TABLE onprc_billing.ogaSynch ADD [OGA_AWARD_START_DATE] DATE Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [OGA_AWARD_END_DATE] DATE Null;
GO
ALTER TABLE onprc_billing.ogaSynch ADD [IndirectRate] Float Null;