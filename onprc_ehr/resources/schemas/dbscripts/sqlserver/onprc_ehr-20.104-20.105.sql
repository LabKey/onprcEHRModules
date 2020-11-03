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

CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_PROTOCOLS](
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
