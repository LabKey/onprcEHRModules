CREATE TABLE onprc_ehr_compliancedb.employeeAssignedLocation
(
    RowId INT IDENTITY(1,1) NOT NULL,
    employeeid varchar(255) not null,
    location varchar(255)  null,
    created datetime,
    createdby USERID,
    modified datetime,
    modifiedBy USERID,
    objectid  varchar(4000),
    container varchar(4000)

        CONSTRAINT PK_employeeAssignedLocation PRIMARY KEY (RowId)
);
GO

CREATE TABLE onprc_ehr_compliancedb.Employeetraining_Details
(
    RowId INT IDENTITY(1,1) NOT NULL,
    employeeid varchar(255) not null,
    requirementname  varchar(3000)  null,
    date_completed datetime,
    required_training varchar(50),
    objectid  varchar(4000),
    container varchar(4000),
    unit     varchar(1000),
    category varchar(1000),
    comments  varchar(2000),
    createdby smallint,
    created   datetime,
    modifiedby  smallint,
    modified datetime

        CONSTRAINT PK_employeetrainingdetails PRIMARY KEY (RowId)
);
GO

insert into onprc_ehr_compliancedb.EmployeeAssignedLocation
  (
  employeeid,
  location,
  created,
  createdby,
  modified,
  modifiedby,
  objectid,
  container
  )



select distinct employeeid,
                replace(requirementname,'Area Training - ',''),
                getdate(),
                1007,
                getdate(),  ----modified
                1007,
                newid(),   ---objectid
                'CD170458-C55F-102F-9907-5107380A54BE'  ----container
from onprc_ehr_compliancedb.Employeetraining_Details where  requirementname like 'area training%'

Go

Insert into onprc_ehr_compliancedb.Employeetraining_Details
(employeeid,
 requirementname,
 date_completed,
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
Where  (b.unit = e.unit )
  And e.employeeid  in (select distinct kk.employeeid from ehr_compliancedb.Employees kk where kk.enddate is null)

group by e.employeeid, b.requirementname

GO