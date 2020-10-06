CREATE TABLE onprc_ehr.Reference_StaffNames(
	 RowId                    INT IDENTITY(1,1)NOT NULL,
   username                 varchar(100),
   LastName                 varchar(100) NULL,
	 FirstName                varchar(100) NULL,
	 displayname               varchar(100) NULL,
	 Type                     varchar(100) NULL,
	 role                     varchar(100) NULL,
   remark                   varchar(200) NULL,
   SortOrder                smallint  NULL,
   StartDate                smalldatetime NULL,
   DisableDate              smalldatetime NULL

    CONSTRAINT pk_reference PRIMARY KEY (username)

);