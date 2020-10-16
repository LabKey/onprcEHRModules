-- includes content of onprc_ehr-12.395-12.396.sql to onprc_ehr-17.704-17.705.sql from onprc19.1Prod

/****** Object:  StoredProcedure [onprc_ehr].[etl1_eIACUCtoPRIMEProcessing]    Script Date: 2/7/2018 2:01:46 PM ******/
Create PROCEDURE onprc_ehr.etlStep1eIACUCtoPRIMEProcessing
AS
Begin

Update  [onprc_ehr].[PRIME_VIEW_PROTOCOL_Processing]
set modifiedby = 000,modified = GetDate()
    where modified is Null



INSERT INTO [onprc_ehr].[PRIME_VIEW_PROTOCOL_Processing]
(
    [Protocol_ID]
,[Template_OID]
,[Protocol_OID]
,[Protocol_Title]
,[PI_ID]
,[PI_First_Name]
,[PI_Last_Name]
,[PI_Email]
,[PI_Phone]
,[USDA_Level]
,[ProcessDate]
,[Approval_Date]
,[Annual_Update_Due]
,[Three_year_Expiration]
,[Last_Modified]
,created
,createdby
,recordStatus
,PPQ_Numbers
,PROTOCOL_State


)
Select
    Distinct
    e.Protocol_ID,
    e.Template_OID,
    CONVERT(BINARY(16),e.Protocol_OID,2) as Protocol_OID,
    e.Protocol_Title,
    e.PI_ID,
    e.PI_First_Name,
    e.PI_Last_Name,
    e.PI_Email,
    e.PI_Phone,
    e.USDA_Level,
    GetDate () as ProcessDate,
    e.Approval_Date,
    e.Annual_Update_Due,
    e.Three_year_Expiration,
    e.Last_Modified,
    GetDate(),
    1011,

    Case
        When e.protocol_ID in
             (Select e1.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e1 left outer join  onprc_ehr.protocol p on p.external_id = e1.protocol_id where p.external_ID is Null) then 'new Record'
        --in the update state we look at each possible area for change
        When e.protocol_ID in
             (Select e1.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e1
                                              left outer join  onprc_ehr.protocol p on p.external_id = e1.protocol_id
              where e1.Template_OID <> p.template_oid) then 'Update TemplateOID'
        When e.protocol_ID in
             (Select e2.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e2
                                              left outer join  onprc_ehr.protocol p on p.external_id = e2.protocol_id
              where e2.PPQ_numbers <> p.PPQ_Numbers) then 'Update PPQ Change'
        When e.protocol_ID in
             (Select e3.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e3
                                              left outer join  onprc_ehr.protocol p on p.external_id = e3.protocol_id
              where e3.Protocol_State <> p.PROTOCOL_State) then 'Update Protocol State'
        When e.protocol_ID in
             (Select e4.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e4
                                              left outer join  onprc_ehr.protocol p on p.external_id = e4.protocol_id
              where e4.Protocol_Title <> p.title) then 'Update Protocol Title'
        else 'No Change'
        End as RecordStatus
        ,e.PPQ_Numbers
        ,e.PROTOCOL_State

from [onprc_ehr].[PRIME_VIEW_PROTOCOLS] e




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
 * This script creates the ONPRC_EHR.animalGroups Dataset which is populated by the ETL Process
 *
 */
CREATE TABLE [onprc_ehr].[PRIME_VIEW_ANIMAL_GROUPS](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Parent_Protocol] [varchar](255) NOT NULL,
    [Group_ID] [varchar](255) NULL,
    [Group_Name] [varchar](255) NULL,
    [Species] [varchar](255) NULL,
    [SPF_Status] [varchar](255) NULL,
    [Weight_Start] [varchar](255) NULL,
    [Weight_End] [varchar](255) NULL,
    [Age_Start] [varchar](255) NULL,
    [Age_End] [varchar](255) NULL,
    [Gender] [varchar](255) NULL,
    [Number_of_Animals_Max] [int] NULL,
    [Non_Standard_Housing_Types] [nvarchar](max) NULL,
    [Non_Standard_Housing_Description] [ntext] NULL,
    [Non_Standard_Housing_Frequency_and_Duration] [ntext] NULL,
    [Non_Standard_Housing_Monitoring] [ntext] NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL,
    [Restraint] [nvarchar](max) NULL,
    [Nutritional_Manipulation_Description] [ntext] NULL,
    [Nutritional_Manipulation_Adverse_Consequences] [nvarchar](255) NULL,
    [Nutritional_Manipulation_Health_Assessment] [nchar](10) NULL,
    [Non_Pharmaceutical_Grade_Drug_Use] [ntext] NULL,
    [Food_Withheld] [int] NULL,
    [Water_Withheld] [int] NULL,
    [Food_Water_Withheld_Description] [ntext] NULL,
    [Food_Water_Withheld_Justification] [ntext] NULL,
    [Food_Water_Withheld_Adverse_Consequences] [ntext] NULL,
    [Death_As_Endpoint_Number_of_Animals] [nvarchar](255) NULL,
    [Death_As_Endpoint_Justification] [ntext] NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

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
 * This script creates the ONPRC_EHR.IBC_Numberss Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[PRIME_VIEW_IBC_NUMBERS](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Animal_Group] [varchar](255) NOT NULL,
    [IBC_Registration_Number] [varchar](255) NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.PRIME_VIEW_NON_SURGICAL_PROCS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[PRIME_VIEW_NON_SURGICAL_PROCS](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Animal_Group] [varchar](255) NOT NULL,
    [NS_Procedure_Name] [varchar](255) NULL,
    [Standard_Procedure] [int] NULL,
    [Iterations] [int] NULL,
    [Deviation] [int] NULL,
    [Deviation_Description] [varchar](255) NULL,
    [Recovery_Days] [int] NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.PRIME_VIEW_PROTOCOL_Processing Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[PRIME_VIEW_PROTOCOL_Processing](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Protocol_ID] [varchar](255) NOT NULL,
    [Template_OID] [varchar](32) NULL,
    [Protocol_OID] [binary](16) NULL,
    [Protocol_Title] [varchar](255) NULL,
    [PI_ID] [varchar](255) NULL,
    [PI_First_Name] [varchar](255) NULL,
    [PI_Last_Name] [varchar](255) NULL,
    [PI_Email] [varchar](255) NULL,
    [PI_Phone] [varchar](255) NULL,
    [USDA_Level] [varchar](255) NULL,
    [ProcessDate] [datetime] NULL,
    [Approval_Date] [datetime] NULL,
    [Annual_Update_Due] [datetime] NULL,
    [Three_year_Expiration] [datetime] NULL,
    [Last_Modified] [datetime] NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL,
    [recordstatus] [nchar](25) NULL,
    [PROTOCOL_STATE] [varchar](100) NULL,
    [PPQ_Numbers] [varchar](255) NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.PRIME_VIEW_PROTOCOLS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[PRIME_VIEW_PROTOCOLS](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Protocol_ID] [varchar](255) NOT NULL,
    [Template_OID] [varchar](32) NULL,
    [Protocol_OID] [varchar](255) NULL,
    [Protocol_Title] [varchar](255) NULL,
    [PI_ID] [varchar](255) NULL,
    [PI_First_Name] [varchar](255) NULL,
    [PI_Last_Name] [varchar](255) NULL,
    [PI_Email] [varchar](255) NULL,
    [PI_Phone] [varchar](255) NULL,
    [USDA_Level] [varchar](255) NULL,
    [Approval_Date] [datetime] NULL,
    [Annual_Update_Due] [datetime] NULL,
    [Three_year_Expiration] [datetime] NULL,
    [Last_Modified] [datetime] NULL,
    [createdby] [int] NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NULL,
    [modified] [datetime] NULL,
    [PROTOCOL_State] [varchar](250) NULL,
    [PPQ_Numbers] [varchar](255) NULL,
    [Description] [varchar](255) NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.PRIME_VIEW_SURGICAL_PROCS Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[PRIME_VIEW_SURGICAL_PROCS](
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [OID] [int] NOT NULL,
    [Animal_Group] [varchar](255) NOT NULL,
    [Standard_Procedure] [int] NULL,
    [Iterations] [int] NULL,
    [Deviation] [int] NULL,
    [Deviation_Description] [varchar](255) NULL,
    [Recovery_Days] [int] NULL,
    [Surgery_Name] [varchar](255) NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.project Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[project](
    [project] [int] NOT NULL,
    [protocol] [varchar](200) NULL,
    [account] [varchar](200) NULL,
    [inves] [varchar](200) NULL,
    [avail] [varchar](100) NULL,
    [title] [varchar](200) NULL,
    [research] [bit] NULL,
    [reqname] [varchar](200) NULL,
    [createdby] [int] NOT NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NOT NULL,
    [modified] [datetime] NULL,
    [contact_emails] [varchar](4000) NULL,
    [startdate] [datetime] NULL,
    [enddate] [datetime] NULL,
    [inves2] [varchar](200) NULL,
    [name] [varchar](100) NULL,
    [investigatorId] [int] NULL,
    [use_category] [varchar](100) NULL,
    [alwaysavailable] [bit] NULL,
    [shortname] [varchar](200) NULL,
    [projecttype] [varchar](100) NULL,
    [container] [uniqueidentifier] NULL,
    [objectid] [uniqueidentifier] NOT NULL
    ) ON [PRIMARY]
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
 * This script creates the ONPRC_EHR.protocol Dataset which is populated by the ETL Process
 *
 */

CREATE TABLE [onprc_ehr].[protocol](
    [rowId] [int] IDENTITY(1,1) NOT NULL,
    [protocol] [varchar](200) NOT NULL,
    [inves] [varchar](200) NULL,
    [approve] [datetime] NULL,
    [description] [text] NULL,
    [createdby] [int] NOT NULL,
    [created] [datetime] NULL,
    [modifiedby] [int] NOT NULL,
    [modified] [datetime] NULL,
    [maxanimals] [int] NULL,
    [enddate] [datetime] NULL,
    [title] [varchar](1000) NULL,
    [usda_level] [varchar](100) NULL,
    [external_id] [varchar](200) NULL,
    [project_type] [varchar](200) NULL,
    [ibc_approval_required] [bit] NULL,
    [ibc_approval_num] [varchar](200) NULL,
    [investigatorId] [int] NULL,
    [last_modification] [datetime] NULL,
    [first_approval] [datetime] NULL,
    [container] [uniqueidentifier] NULL,
    [objectid] [uniqueidentifier] NOT NULL,
    [lastAnnualReview] [datetime] NULL,
    [PROTOCOL_State] [varchar](250) NULL,
    [PPQ_Numbers] [varchar](255) NULL,
    [template_oid] [varchar](255) NULL,
    [Restraint] [varchar](255) NULL
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
 * This script creates the Stored Procedure etl1_eIACUCtoPRIMEProcessing
 *
 */

/****** Object:  StoredProcedure [onprc_ehr].[etl1_eIACUCtoPRIMEProcessing]    Script Date: 2/7/2018 2:01:46 PM ******/
CREATE PROCEDURE [onprc_ehr.etlStep1eIACUCtoPRIMEProcessing]

AS


Begin

Update  [onprc_ehr].[PRIME_VIEW_PROTOCOL_Processing]
set modifiedby = 000,modified = GetDate()
    where modified is Null



INSERT INTO [onprc_ehr].[PRIME_VIEW_PROTOCOL_Processing]
(
    [Protocol_ID]
,[Template_OID]
,[Protocol_OID]
,[Protocol_Title]
,[PI_ID]
,[PI_First_Name]
,[PI_Last_Name]
,[PI_Email]
,[PI_Phone]
,[USDA_Level]
,[ProcessDate]
,[Approval_Date]
,[Annual_Update_Due]
,[Three_year_Expiration]
,[Last_Modified]
,created
,createdby
,recordStatus
,PPQ_Numbers
,PROTOCOL_State


)
Select
    Distinct
    e.Protocol_ID,
    e.Template_OID,
    CONVERT(BINARY(16),e.Protocol_OID,2) as Protocol_OID,
    e.Protocol_Title,
    e.PI_ID,
    e.PI_First_Name,
    e.PI_Last_Name,
    e.PI_Email,
    e.PI_Phone,
    e.USDA_Level,
    GetDate () as ProcessDate,
    e.Approval_Date,
    e.Annual_Update_Due,
    e.Three_year_Expiration,
    e.Last_Modified,
    GetDate(),
    1011,

    Case
        When e.protocol_ID in
             (Select e1.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e1 left outer join  onprc_ehr.protocol p on p.external_id = e1.protocol_id where p.external_ID is Null) then 'new Record'
        --in the update state we look at each possible area for change
        When e.protocol_ID in
             (Select e1.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e1
                                              left outer join  onprc_ehr.protocol p on p.external_id = e1.protocol_id
              where e1.Template_OID <> p.template_oid) then 'Update TemplateOID'
        When e.protocol_ID in
             (Select e2.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e2
                                              left outer join  onprc_ehr.protocol p on p.external_id = e2.protocol_id
              where e2.PPQ_numbers <> p.PPQ_Numbers) then 'Update PPQ Change'
        When e.protocol_ID in
             (Select e3.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e3
                                              left outer join  onprc_ehr.protocol p on p.external_id = e3.protocol_id
              where e3.Protocol_State <> p.PROTOCOL_State) then 'Update Protocol State'
        When e.protocol_ID in
             (Select e4.protocol_ID from  onprc_ehr.PRIME_VIEW_PROTOCOLS e4
                                              left outer join  onprc_ehr.protocol p on p.external_id = e4.protocol_id
              where e4.Protocol_Title <> p.title) then 'Update Protocol Title'
        else 'No Change'
        End as RecordStatus
        ,e.PPQ_Numbers
        ,e.PROTOCOL_State

from [onprc_ehr].[PRIME_VIEW_PROTOCOLS] e




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

