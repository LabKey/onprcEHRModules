CREATE TABLE onprc_ehr.NHP_Training(
	 RowId INT IDENTITY(1,1)NOT NULL,
   Id                  varchar(100),
	 date                datetime  NULL,
   training_Ending_Date datetime NULL,
	 training_type        varchar(255) NULL,
	 reason              varchar(255) NULL,
	 qcstate              INTEGER    NULL,
   taskid 	             nvarchar(4000) NULL,
   remark              nvarchar(4000) NULL,
   objectid 	          ENTITYID NOT NULL,
   formSort             SMALLINT  NULL,
   performedby   	      nvarchar(4000) NULL,
	 createdby            int NULL,
	 created              datetime NULL,
	 modifiedby           int NULL,
	 modified             datetime  NULL,
	 Container 	          ENTITYID,
	 training_results     varchar(255) NULL

 CONSTRAINT PK_NHPTrainingObject PRIMARY KEY (objectid)
);