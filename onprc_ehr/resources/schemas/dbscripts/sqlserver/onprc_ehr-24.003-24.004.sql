-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
--   Added updatge for Latest Renewal in the Stored Procedure
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonesga
-- Create date: 2024/07/25
-- Description:	Iniitial Stage of update of eIACUC to protocol processing
    -- Stored Procedure did not process, will retry
-- =============================================
--DROP PROCEDURE onprc_ehr.eIACUCBaseProtocol;
IF OBJECT_ID('eIACUCBaseProtocol', 'P') IS NOT NULL
DROP PROC eiACUCtoProtocolPhase2

GO

/****** Object:  StoredProcedure [onprc_ehr].[eIACUCBaseProtocolPhase2]    Script Date: 7/29/2024 9:10:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [onprc_ehr].[eIACUCBaseProtocolPhase2]

    AS
BEGIN


	SET NOCOUNT ON;

Update p1
Set p1.enddate = e.last_Modified, p1.contacts= 'Enddate as expired in eIACUC2'
    from ehr.protocol1 p1 join onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS  e on p1.external_ID = e.BaseProtocol
where(p1.enddate is null and e.protocol_State = 'expired' and e.LatestRenewal = 1)


END
GO
