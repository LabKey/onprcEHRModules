/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]    Script Date: 10/15/2020 9:30:00 AM ******/
DROP PROCEDURE IF EXISTS [onprc_billing].[ClearOGASync]
    GO

CREATE PROCEDURE [onprc_billing].[ClearOGASync]
AS
BEGIN

Delete from onprc_billing.ogasynch




END
