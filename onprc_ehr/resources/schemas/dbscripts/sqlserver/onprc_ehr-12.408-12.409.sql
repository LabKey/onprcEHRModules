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

USE [Labkey]
GO
/****** Object:  StoredProcedure [onprc_ehr].[etl2_update_ehrProtocol]    Script Date: 2/7/2018 2:29:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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