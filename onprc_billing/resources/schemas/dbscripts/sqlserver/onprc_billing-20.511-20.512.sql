
/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]
  cREATED 2020-05-18
    cREATED BY JONESGA
  Purpose:  Resets the Alias Dataset for Insert from OGA, Keeping GL Accounts

  Script Date: 5/18/2020 10:33:15 AM ******/
DROP PROCEDURE IF EXISTS [onprc_billing].[OGA_RemoveRecords]
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [onprc_billing].[OGA_RemoveRecords]
    AS
    BEGIN

        Delete from onprc_billing.aliases
        where category != 'OHSU GL'



    END