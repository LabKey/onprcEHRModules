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