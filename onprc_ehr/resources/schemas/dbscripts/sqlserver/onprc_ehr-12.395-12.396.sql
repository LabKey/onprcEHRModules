/*
 * Copyright (c) 2016-2017 LabKey Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
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
 * This stored Procedure is part of the eIACUC ETL process and is being added her to create the Stored Procedures in the
 * SQL 2014 DB for Labkey-gj
 */

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