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
 * 2020/1/24 Update of Fields to accomodate incoming text straing.
 * Manual updated the Database schema to verify that it resolved the issue
 * This script creates the ONPRC_EHR.animalGroups Dataset which is populated by the ETL Process
 *
 */


/****** Object:  Table [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]    Script Date: 1/24/2020 12:23:44 PM ******/
DROP TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]
GO

/****** Object:  Table [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS]    Script Date: 1/24/2020 12:23:44 PM ******/
CREATE TABLE [onprc_ehr].[eIACUC_PRIME_VIEW_ANIMAL_GROUPS](
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
	[Breeding_Colony] [int] NULL,
	[Non_Standard_Housing_Types] [nvarchar](max) NULL,
	[Non_Standard_Housing_Description] [ntext] NULL,
	[Non_Standard_Housing_Frequency_and_Duration] [nvarchar](max) NULL,
	[Non_Standard_Housing_Monitoring] [nvarchar](max) NULL,
	[createdby] [int] NULL,
	[created] [datetime] NULL,
	[modifiedby] [int] NULL,
	[modified] [datetime] NULL,
	[Restraint] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Description] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Adverse_Consequences] [nvarchar](max) NULL,
	[Nutritional_Manipulation_Health_Assessment] [nvarchar](max) NULL,
	[Non_Pharmaceutical_Grade_Drug_Use] [ntext] NULL,
	[Food_Withheld] [int] NULL,
	[Water_Withheld] [int] NULL,
	[Food_Water_Withheld_Description] [nvarchar](max) NULL,
	[Food_Water_Withheld_Justification] [nvarchar](max) NULL,
	[Food_Water_Withheld_Adverse_Consequences] [nvarchar](max) NULL,
	[Death_As_Endpoint_Number_of_Animals] [nvarchar](max) NULL,
	[Death_As_Endpoint_Justification] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


