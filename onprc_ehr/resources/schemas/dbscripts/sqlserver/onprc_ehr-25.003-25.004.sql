
CREATE TABLE onprc_ehr.RequirementName_Convert(
    searchid integer IDENTITY(100,1) NOT NULL,
    PreviousDesignation varchar(255) NULL,
    afterName varchar(255) NULL,
    FileName varchar(1000) NULL
    ) ON [PRIMARY]
    GO


/*
**
**	 Created by	Date		Comment
**
**
**  	Blasa      1/6/2026     Convert Compliance Requirement Names to its new predefined names.
*/


CREATE Procedure 	sp_Compliance_requirementname_Update_Process




AS

DECLARE

                  @SearchKey          Int,
			      @TempsearchKey	  Int,
                  @Code               varchar(500)
Begin



                 ---Initial Values
                   set @TempSearchkey = 0
                   set @Searchkey = 0



select top 1 @Searchkey= searchid  from onprc_ehr.requirementname_Convert
order by searchid


While @TempSearchKey < @SearchKey
BEGIN

select top 1 @Code=PreviousDesignation  from onprc_ehr.requirementname_Convert
    Where searchid = @Searchkey

    If @@Error <> 0
        			 GoTo Err_Proc

      ------Process Requirement Names

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.Requirements ss, onprc_ehr.requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                        And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc

------Process Completion Dates

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.CompletionDates ss, onprc_ehr.requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                                  And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc

------Process Requirements for Employees

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.RequirementsPerEmployee ss, onprc_ehr.requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                                     And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc

-----Process Requirements per Categories

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.RequirementsPerCategory ss, onprc_ehr.requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                                             And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc

-----Process Employee Requirements Exemptions

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.EmployeeRequirementExemptions ss, onprc_ehr.requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                                             And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc


----- Process the next  data record

Set @TempSearchkey = @SearchKey


select top 1 @Searchkey= searchid  from onprc_ehr.requirementname_Convert
Where searchid > @TempSearchkey
order by searchid

    If @@Error <> 0
         			GoTo Err_Proc


END  ---(While)



RETURN 0


    Err_Proc:


	RETURN 1


END

GO


