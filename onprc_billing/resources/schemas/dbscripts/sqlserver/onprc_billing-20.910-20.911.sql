/****** Object:  StoredProcedure [onprc_billing].[OGA_RemoveRecords]    Script Date: 10/15/2020 9:30:00 AM ******/

EXEC core.fn_dropifexists 'ClearOGASync', 'onprc_billing', 'PROCEDURE'
GO

CREATE PROCEDURE [onprc_billing].[ClearOGASync]
AS
BEGIN

Delete from onprc_billing.ogasynch

END

GO
