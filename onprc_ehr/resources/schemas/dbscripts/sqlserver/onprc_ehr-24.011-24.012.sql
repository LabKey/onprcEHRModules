CREATE TABLE onprc_ehr.CenterProjectsTemp(
    [searchid] [int] IDENTITY(100,1) NOT NULL,
    [project] [smallint] NULL,
    [protocol] [smallint] NULL,
    [account] [varchar](1000) NULL,
    [title] [varchar](2000) NULL,
    [research] [smallint] NULL,
    [createdby] [smallint] NULL,
    [created] [datetime] NULL,
    [modified] [datetime] NULL,
    [modifiedby] [smallint] NULL,
    [startdate] [datetime] NULL,
    [enddate] [datetime] NULL,
    [displayname] [varchar](1000) NULL,
    [investigatorid] [smallint] NULL,
    [use_category] [varchar](500) NULL,
    [projecttype] [varchar](500) NULL,
    [objectid] [varchar](max) NULL,
    [date_posted] [datetime] NULL

 ) ON [PRIMARY]
    GO


/*
**
** 	Created by
**      Blasa  		5/31/2025                   Process to create Center Projects historical records
**

**
**
**
**
*/

CREATE Procedure onprc_ehr.p_CenterProjectsHistoricalProcess


    AS

BEGIN



    ---- Reset temp table

         Delete onprc_ehr.CenterProjectsTemp


	 If @@Error <> 0
	  GoTo Err_Proc


   Insert into  onprc_ehr.CenterProjectsTemp
     (
    project,
	protocol,
	account,
	title,
	research,
	createdby,
	created,
	modified,
	modifiedby,
	startdate,
	enddate,
	displayname,
	investigatorid,
	use_category,
	projecttype,
	objectid,
	date_posted
        )

Select
    project,
    protocol,
    account,
    title,
    research,
    createdby,
    created,
    modified,
    modifiedby,
    startdate,
    enddate,
    name,                 -----displayname
    investigatorid,
    use_category,
    projecttype,
    objectid,
    getdate()

From ehr.project where (enddate is null or enddate >= getdate())
                   And modified >= cast(getdate()) as date)
order by modified



    If @@Error <> 0
	  GoTo Err_Proc




 RETURN 0


Err_Proc:
                    -------Error Generated, Transfer process stopped
	RETURN 1


END

