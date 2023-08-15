IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'UpdateLabEndDate')
DROP PROCEDURE ALIASCleanup202004
    GO
CREATE PROCEDURE onprc_billing.UpdateLabEndDate

    AS
BEGIN
    --Updates end Date for ClinPath when complete but no dateUpdate [Labkey_uat].[studyDataset].[c6d199_clinpathruns]
Update [studyDataset].[c6d199_clinpathruns]
set datefinalized =  date
where dateFinalized is null and date > '5/1/2023' and qcstate = 18





END
GO
