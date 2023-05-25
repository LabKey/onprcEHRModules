/*This sql will remove unused tables that are not in an xml definition per Conisstency check
    Compelted 5/25/2023 jonesga*/

GO

DELETE FROM [onprc_ehr].[PrimeProblemListMaster]
WHERE <Search Conditions,,>
    GO
/*cleanup of extscheduler orphan Files*/

    GO

DELETE FROM [extscheduler].[vw_Covid19Research]
WHERE <Search Conditions,,>
    GO

    GO

DELETE FROM [extscheduler].[Covid19Testing]
WHERE <Search Conditions,,>
    GO

DELETE FROM [extscheduler].[vw_Covid19DCMDaily]
WHERE <Search Conditions,,>
    GO

    GO

DELETE FROM [sla].[vendors_new]
WHERE <Search Conditions,,>
    GO

DELETE FROM [sla].[requestors_new]
WHERE <Search Conditions,,>
    GO
DELETE FROM [onprc_billing].[AnnualInflationRate]
WHERE <Search Conditions,,>
    GO



