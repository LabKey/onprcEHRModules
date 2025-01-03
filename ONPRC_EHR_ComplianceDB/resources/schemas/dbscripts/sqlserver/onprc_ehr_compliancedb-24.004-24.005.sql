

EXEC core.fn_dropifexists 'p_ComplianceAccesscontainerUpdate', 'onprc_ehr_compliancedb', 'PROCEDURE';
GO

-- Author:	R. Blasa
-- Created: 12-10-2024

/*
**
** 	Created by
**      Blasa  		12-10-2024               Storedprocedure to update string name "ARRS" to "DCM"
**
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.p_ComplianceTranslatestringUpdate


AS



BEGIN

          ------ Update container value and include as part of the main Compliance module

If exists(select * from ehr_compliancedb.EmployeePerUnit         ------> count= 496
          where unit like '%arrs%'
 )
BEGIN

      Update  ehr_compliancedb.EmployeePerUnit
          set unit = replace(unit,'arrs', 'DCM')



                If @@Error <> 0
                     GoTo Err_Proc

 END


 If exists(select * from ehr_compliancedb.EmployeePerUnit         ------> count= 496
           where  category like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.EmployeePerUnit
           set category = replace(category,'arrs', 'DCM')



                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where majorudds  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set majorudds   = replace(majorudds,'arrs', 'DCM')



                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where unit  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set unit = replace(unit,'arrs', 'DCM')

                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.Employees
               where  category  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.Employees
           set category = replace(category,'arrs', 'DCM')

                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.requirements
               where requirementname  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.requirements
           set requirementname = replace(requirementname,'arrs', 'DCM')


                 If @@Error <> 0
                      GoTo Err_Proc

  END



 If exists(select * from ehr_compliancedb.EmployeeRequirementExemptions
               where requirementname  like '%arrs%'
  )
 BEGIN

       Update  ehr_compliancedb.EmployeeRequirementExemptions
           set requirementname = replace(requirementname,'arrs', 'DCM')


                 If @@Error <> 0
                      GoTo Err_Proc

  END




   If exists(select * from ehr_compliancedb.unit_names
             where unit  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.unit_names
             set unit = replace(unit,'arrs', 'DCM')



                   If @@Error <> 0
                        GoTo Err_Proc

    END


   If exists(select * from ehr_compliancedb.RequirementsPerCategory
                 where RequirementName  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.RequirementsPerCategory
             set requirementname = replace(requirementname,'arrs', 'DCM')



                   If @@Error <> 0
                        GoTo Err_Proc

    END


 If exists(select * from ehr_compliancedb.RequirementsPerCategory
           where category  like '%arrs%'
    )
   BEGIN

         Update  ehr_compliancedb.RequirementsPerCategory
             set category = replace(category,'arrs', 'DCM')

                   If @@Error <> 0
                        GoTo Err_Proc

    END


   If exists(select * from ehr_compliancedb.RequirementsPerCategory
             where unit  like '%arrs%'
      )
     BEGIN

        Update  ehr_compliancedb.RequirementsPerCategory
            set unit = replace(unit,'arrs', 'DCM')


                     If @@Error <> 0
                          GoTo Err_Proc

      END

  If exists(select * from ehr_compliancedb.completiondates
                           where  requirementname  like '%arrs%'
     )
    BEGIN

                 Update  ehr_compliancedb.completiondates
                     set requirementname = replace(requirementname,'arrs', 'DCM')


                    If @@Error <> 0
                         GoTo Err_Proc

     END

  If exists(select * from ehr_compliancedb.EmployeeCategory
            where categoryname  like '%arrs%'
     )
    BEGIN

          Update   ehr_compliancedb.EmployeeCategory
                 set categoryname  = replace(categoryname ,'arrs', 'DCM')


                    If @@Error <> 0
                         GoTo Err_Proc

     END








No_Records:

 RETURN 0


Err_Proc:
                    --
	RETURN 1


END

GO