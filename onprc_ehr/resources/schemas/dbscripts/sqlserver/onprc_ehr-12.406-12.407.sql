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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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