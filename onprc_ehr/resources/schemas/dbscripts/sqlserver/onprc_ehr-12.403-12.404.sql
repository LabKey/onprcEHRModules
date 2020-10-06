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