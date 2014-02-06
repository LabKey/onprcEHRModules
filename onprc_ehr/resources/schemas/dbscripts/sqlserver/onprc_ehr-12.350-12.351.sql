/*
 * Copyright (c) 2014 LabKey Corporation
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
 */
--added to facilitate the split billing code into a separate module from ONPRC_EHR.
--this should cause the server to think all existing scripts were in fact run, even though they ran as the onprc_ehr module
INSERT INTO core.SqlScripts (Created, Createdby, Modified, Modifiedby, FileName, ModuleName)
SELECT Created, Createdby, Modified, Modifiedby, FileName, 'ONPRC_Billing' as ModuleName
FROM core.SqlScripts
WHERE FileName LIKE 'onprc_billing-%'AND ModuleName = 'ONPRC_EHR';