/*
 * Copyright (c) 2020-2026 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
 */

/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]
  cREATED 2020-05-18
    cREATED BY JONESGA
  Purpose:  Resets the Alias Dataset for Insert from OGA, Keeping GL Accounts

  Script Date: 5/18/2020 10:33:15 AM ******/
EXEC core.fn_dropifexists 'OGA_RemoveRecords', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[OGA_RemoveRecords]
    AS
    BEGIN

        Delete from onprc_billing.aliases
        where category != 'OHSU GL'



    END

GO
