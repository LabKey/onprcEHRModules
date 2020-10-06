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