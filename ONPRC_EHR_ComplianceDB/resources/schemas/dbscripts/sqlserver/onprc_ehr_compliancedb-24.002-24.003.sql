


-- Author:	R. Blasa
-- Created: 3-21-2024
-- Description:	Stored procedure program process SciShield INitial Data
CREATE TABLE onprc_ehr_compliancedb.EmployeeTraining_Details
(
    rowId INT IDENTITY(100,1) NOT NULL,
    EmployeeId nvarchar(255) not null,
    [requirementname] [nvarchar](3000) NULL,
    [datecompleted] [datetime] NULL,
    [next_training] [nvarchar](50) NULL,
    [next_training_date] [datetime] NULL,
    [required_training] [nchar](10) NULL,
    [objectid] [dbo].[ENTITYID] NULL,
    [comments] [char](500) NULL,
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,
    taskid entityid,
    unit nvarchar(1000),
    category nvarchar(1000)



        CONSTRAINT PK_EmployeeTraining PRIMARY KEY (rowId)
    );

CREATE TABLE onprc_ehr_compliancedb.Employee_Reference_Data
(
    rowId int identity(1,1),
    label varchar(250) NULL,
    value varchar(255) ,
    columnName varchar(255)  NOT NULL,
    sort_order integer  null,
    endDate  datetime  NULL,
    objectid entityid

        CONSTRAINT pk_compliance_employee

            PRIMARY KEY (value)

);


CREATE TABLE onprc_ehr_compliancedb.Employee_Assigned_Location
(
    rowId int identity(1,1),
    location varchar(500) NULL,
    employeeid varchar(255),
    status varchar(255) ,
    endDate  datetime  NULL,
    comments   varchar(500) NULL,
    Container ENTITYID NOT NULL,
    CreatedBy USERID,
    Created datetime,
    ModifiedBy USERID,
    Modified datetime,
    taskid entityid,
    sort_order integer  null,
    objectid entityid

        CONSTRAINT pk_employee_location

            PRIMARY KEY (objectid)

);



-- Author:	R. Blasa
-- Created: 2-10-2024

/*
**
** 	Created by
**      Blasa  		1-25-2024         Process to format Complance report as an excel table.
**
**
**
**
**
*/

CREATE Procedure onprc_ehr_compliancedb.[p_SciShieldToPrimeProcess]


AS


DECLARE
                          @SearchKey               Int,
			              @TempsearchKey	       Int,


BEGIN

    ---- Reset temp table

         Delete onprc_ehr_compliancedb.SciShieldTemp


	       If @@Error <> 0
	           GoTo Err_Proc


IF exists (Select count(*) from onprc_ehr_compliancedb.Employeetraining_Details) = 0
BEGIN

 Insert into onprc_ehr_compliancedb.Employeetraining_Details
    (employeeid,
	 requirementname,
	 datecompleted,
	 required_training,
	 objectid,
	 container,
	 unit,
	 category,
	 comments,
	 createdby,
	 created,
	 modifiedby,
	 modified
	 )

select
    e.employeeid,


    b.requirementname,


    (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid   ) as completiondate,

    'yes' as required_training,

    newid() as objectid,

    'CD170458-C55F-102F-9907-5107380A54BE' as container,

    string_agg(e.unit, char(10)) ,

    string_agg( e.category, char(10)) ,


    (select string_agg( k.comment, char(10)) from ehr_compliancedb.completiondates k where k.requirementname = b.requirementname and k.employeeid = e.employeeid
                                                                                       And k.date in (select max(zz.date) from ehr_compliancedb.completiondates zz where zz.requirementname = b.requirementname and zz.employeeid= e.employeeid ))  as comments,
    1007,    ------ createdby
    getdate(),  ------ created
    1007,
    getdate()


from  ehr_compliancedb.requirementspercategory b, ehr_compliancedb.employeeperUnit e
Where  (b.category = e.category  or b.unit = e.unit )
  And e.employeeid  in (select distinct kk.employeeid from ehr_compliancedb.Employees kk where kk.enddate is null)

     group by e.employeeid, b.requirementname

          If @@Error <> 0
	           GoTo Err_Proc

END

No_Records:

 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

GO