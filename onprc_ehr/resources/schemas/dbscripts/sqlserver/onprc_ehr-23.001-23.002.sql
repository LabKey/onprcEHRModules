CREATE TABLE onprc_ehr.Reference_Data_IDkey
(
        rowId int identity(1,1),
        displayName varchar(4000) DEFAULT NULL,
        idkey       integer NOT NULL,
        columnName  varchar(1000)  NOT NULL,
        status      integer NULL,
        type        varchar(500) NULL,
        sort_order  integer  null,
        created     datetime NOT NULL,
        endDate     datetime  DEFAULT NULL


         CONSTRAINT pk_referenceIDkey PRIMARY KEY (idkey)
)


GO


-- Author:	R. Blasa
-- Created: 10-10-2022
-- Description:	Stored procedure program to initially populate onprc_ehr.Reference_Data_IDkey.


Create Procedure [onprc_ehr].[p_PopulateReferenceDataIDkey]


AS


BEGIN
                 ---- Reset lookiup table

              truncate table onprc_ehr.Reference_Data_IDkey

                 ----- Create initial entries
                   Insert into  onprc_ehr.Reference_Data_IDkey
                    select

                           Name,
                           UserId,
                           'Active_Groups',
                           Active,
                           Type,
                           NULL as sort_order,    ---- Sort_Order
                           GETDATE() as created,   ----- Created
                           NULL as enddate     ----- Date Disabled

            FROM core.Principals
                        where type = 'g'
                        and UserId > 0
                        and Active = 1
                        and Container is null

                        If @@Error <> 0
   			      	 GoTo Err_Proc


              Return 0

Err_Proc:    Return 1

END

GO