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

USE [Labkey]
GO
/****** Object:  StoredProcedure [onprc_ehr].[etl3_insertToEhr_Protocol]    Script Date: 2/7/2018 2:30:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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