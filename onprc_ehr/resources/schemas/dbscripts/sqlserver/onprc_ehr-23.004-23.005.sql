/*
 * Copyright (c) 2023-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */
---Create 5-2023-08-15 jonesga

EXEC core.fn_dropifexists 'PrimeProblemListTemp', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'PrimeProblemListMaster', 'onprc_ehr', 'TABLE', NULL;
GO

EXEC core.fn_dropifexists 'p_CaseToPRoblemListupdates', 'onprc_ehr', 'PROCEDURE', NULL;
GO


