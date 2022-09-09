-- includes content of onprc_ehr-12.395-12.396.sql to onprc_ehr-17.704-17.705.sql from onprc19.1Prod

/****** Object:  StoredProcedure [onprc_ehr].[etl1_eIACUCtoPRIMEProcessing]    Script Date: 2/7/2018 2:01:46 PM ******/
Create PROCEDURE onprc_ehr.etlStep1eIACUCtoPRIMEProcessing
AS
Begin


/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.animalGroups Dataset which is populated by the ETL Process
 *
 */



/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 2/17/2018 Jones ga
 * This script creates the ONPRC_EHR.PRIME_VIEW_PROTOCOLS Dataset which is populated by the ETL Process
 *
 */\

    If @@Error <> 0
    GoTo Err_Proc





    Return 0

    Err_Proc:    Return 1




END
    GO
/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 2/17/2018 Jones ga
 * This script creates the Stored Procedure etl1s_eIACUCtoPublicAction
 *
 */

/****** Object:  StoredProcedure [onprc_ehr].[etl.Step1A_eIACUCtoPublicAction]    Script Date: 2/7/2018 2:04:29 PM ******/
Create  PROCEDURE [onprc_ehr].[etl1_eIACUCtoPublicAction]

AS
Begin


INSERT INTO [Labkey_Public].[dbo].[protocolEiacucActions]
([objectid]
,[DateEntered]
,[actionType]
,[Protocol_ID]
,[Date_Modified]
,[Protocol_OID]
,[Template_OID]
,[Protocol_Title]
,[InvestigatorID]
,[PI_ID]
,[PI_First_Name]
,[PI_Last_Name]
,[PI_Email]
,[PI_Phone]
,[USDA_Level]
,[Approval_Date]
,[Annual_Update_Due]
,[Three_year_Expiration]
,[Last_Modified]
,[createdby]
,[created]
,[modifiedby]
,[modified]
,[status]
,[container]
,[PPQ_Numbers]
,[PROTOCOL_State]
,[description]
)



Select
    NewID(),
    null ,
    Case When p.recordStatus like 'update%' then  'update'

         when p.recordStatus = 'New Record' then 'Insert New'

        End 		as ActionType
     ,p.Protocol_ID
     ,p.modified as Date_Modified
     ,p.Protocol_OID
     ,p.Template_OID
     ,p.Protocol_Title
     ,(Select i.rowID from onprc_ehr.investigators i where i.employeeID = p.pi_id and i.dateDisabled is null) as InvestigatorID
     ,p.PI_ID
     ,p.PI_First_Name
     ,p.PI_Last_Name
     ,p.PI_Email
     ,p.PI_Phone
     ,p.USDA_Level
     ,p.Approval_Date
     ,p.Annual_Update_Due
     ,p.Three_year_Expiration
     ,p.Last_Modified
     ,p.createdby
     ,p.created
     ,
    Case
        when p.modifiedby is null then 0000 else p.modifiedby end as modifiedBy,
    Case
        when p.modified is null then getDate() else p.modified end as modified,

    p.recordstatus
     ,'CD17027B-C55F-102F-9907-5107380A54BE'
     ,p.PPQ_Numbers
     ,p.PROTOCOL_State
     ,Case when  p.recordStatus like 'update%' then  ('Update from eIACUC ' + p.recordstatus)
    End as description


FROM onprc_ehr.PRIME_VIEW_Protocol_processing p

where
        p.recordstatus not in  ('processed','No Change')

Update onprc_ehr.PRIME_VIEW_Protocol_processing
Set modified = GetDate(),recordStatus = 'processed', ProcessDate = GetDate()
where modified is null

    If @@Error <> 0
      GoTo Err_Proc





    Return 0

    Err_Proc:    Return 1




END
    GO
/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 2/17/2018 Jones ga
 * This script creates the Stored Procedure etl3_insertToEhr_Protocol
 *
 */

/****** Object:  StoredProcedure [onprc_ehr].[etl3_insertToEhr_Protocol]    Script Date: 2/7/2018 2:30:52 PM ******/
CREATE  PROCEDURE [onprc_ehr].[etl3_insertToEhr_Protocol]

AS

Begin

INSERT INTO [LABKEY].[onprc_ehr].[protocol]
([protocol]	,[approve],[createdby],[created],[modifiedby],[modified],[title]
               ,[usda_level],[external_id],[investigatorId],[last_modification],[objectid],container,PROTOCOL_State,PPQ_Numbers
)
Select
    Protocol_ID,Approval_Date,createdby,created,modifiedby,modified,Protocol_Title
     ,USDA_Level,Protocol_ID,InvestigatorID,Last_Modified,NewID(),'CD17027B-C55F-102F-9907-5107380A54BE',Protocol_State,PPQ_Numbers
FROM [Labkey_Public].dbo.protocolEIACUCActions
Where actionType in ('update','Insert New')
  And dateentered is null

    If @@Error <> 0
    GoTo Err_Proc

Update [Labkey_Public].[dbo].[protocolEiacucActions]
set dateentered = getdate(), status = 'processed'
    Where status not like ('processed')
          And dateentered is null

    Return 0

    Err_Proc:    Return 1


END
    GO
/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 2/17/2018 Jones ga
 * This script creates the Stored Procedure etl2_update_ehrProtocol
 *
 */

/****** Object:  StoredProcedure [onprc_ehr].[etl2_update_ehrProtocol]    Script Date: 2/7/2018 2:29:18 PM ******/
CREATE PROCEDURE [onprc_ehr].[etl2_update_ehrProtocol]

AS

Begin

--reviews the current table and insures that there is only 1 record per protocol




Update prot
Set prot.enddate = getDate(),
    prot.description =  p.description
From onprc_ehr.protocol prot join [labkey_public].dbo.protocolEiacucActions p on prot.external_id = p.protocol_ID
where prot.enddate is null and p.dateEntered is Null
  and prot.objectID in
    (Select e.objectID from onprc_ehr.protocol e, [labkey_public].dbo.protocolEiacucActions p where e.external_ID = p.Protocol_ID and e.enddate is null and p.status like 'Update%')


    If exists (Select * from [Labkey_Public].dbo.protocolEIACUCActions
    where status = 'new import'
  And dateentered is null)


    If @@Error <> 0
    GoTo Err_Proc



    Return 0

    Err_Proc:    Return 1




END
    GO

CREATE TABLE [onprc_ehr].[AvailableBloodVolume](
    [datecreated] [datetime] NULL,
    [id] [nvarchar](32) NULL,
    [gender] [nvarchar](4000) NULL,
    [species] [nvarchar](4000) NULL,
    [yoa] [float] NULL,
    [mostrecentweightdate] [datetime] NULL,
    [weight] [float] NULL,
    [calcmethod] [nvarchar](32) NULL,
    [BCS] [float] NULL,
    [BCSage] [int] NULL,
    [previousdraws] [float] NULL,
    [ABV] [float] NULL,
    [dsrowid] [bigint] NOT NULL
    ) ON [PRIMARY]
    GO

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

CREATE TABLE onprc_ehr.Frequency_DayofWeek(
                                              RowId                    INT IDENTITY(1,1)NOT NULL,
                                              FreqKey                  SMALLINT  NULL,
                                              value                    SMALLINT  NULL,
                                              Meaning                  varchar(400) NULL,
                                              calenderType             varchar(100) NULL,
                                              Sort_order               SMALLINT NULL,
                                              DisableDate              smalldatetime NULL

                                                  CONSTRAINT pk_FreqWeek PRIMARY KEY (RowId)

);

CREATE TABLE onprc_ehr.usersActiveNames(
    Email nvarchar(64) NULL,
    _ts timestamp NOT NULL,
    EntityId ENTITYID NULL,
    CreatedBy USERID NULL,
    Created datetime NULL,
    ModifiedBy USERID NULL,
    Modified datetime NULL,
    Owner USERID NULL,
    UserId USERID NOT NULL,
    DisplayName nvarchar(64) NOT NULL,
    FirstName nvarchar(64) NULL,
    LastName nvarchar(64) NULL,
    Phone nvarchar(64) NULL,
    Mobile nvarchar(64) NULL,
    Pager nvarchar(64) NULL,
    IM nvarchar(64) NULL,
    Description nvarchar(255) NULL,
    LastLogin datetime NULL,
    Active bit NOT NULL
    )
    GO
