/*This sql will remove unused tables that are not in an xml definition per Consistency check
  * Completed 5/25/2023 jones
  * 2nd Try 6-1-2023*/

GO

DELETE FROM [onprc_ehr].[PrimeProblemListMaster]
WHERE <Search Conditions,,>
    GO


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



