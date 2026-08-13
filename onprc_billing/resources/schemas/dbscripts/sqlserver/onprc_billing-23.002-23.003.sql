IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'UpdateClinPathEndDate')
DROP PROCEDURE UpdateClinPathEndDate
    GO
CREATE PROCEDURE onprc_billing.UpdateClinPathEndDate

    AS
BEGIN
    --Updates end Date for ClinPath when complete but no dateUpdate [Labkey_uat].[studyDataset].[c6d199_clinpathruns]
    --update todya 8/16/2023
Update [studyDataset].[c6d199_clinpathruns]
set datefinalized =  date
where dateFinalized is null and date > '5/1/2023' and qcstate = 18





END
GO
