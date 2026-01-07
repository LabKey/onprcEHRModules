
CREATE TABLE [dbo].[RequirementName_Convert](
    [searchid] [smallint] IDENTITY(100,1) NOT NULL,
    [PreviousDesignation] [nvarchar](255) NULL,
    [afterName] [nvarchar](255) NULL,
    [FileName] [nvarchar](255) NULL
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



select top 1 @Searchkey= searchid  from requirementname_Convert
order by searchid


    While @TempSearchKey < @SearchKey

BEGIN

select top 1 @Code=PreviousDesignation  from requirementname_Convert
order by searchid
    If @@Error <> 0
        			 GoTo Err_Proc

Update ss
set ss.RequirementName = '' + trim(jj.aftername) + ' ' + trim(jj.filename) + ''

    from ehr_Compliancedb.Requirements ss, requirementname_Convert jj where ss.RequirementName like  '' + trim(@code) + '%'
                                                                        And jj.PreviousDesignation like '' + trim(@code) + '%'

    If @@Error <> 0
    GoTo Err_Proc

----- Process the next  data record

Set @TempSearchkey = @SearchKey


Select top 1 @Code=PreviousDesignation  from requirementname_Convert
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


