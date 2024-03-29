-- =================================================================================================
-- Create Table for eIACUC Ddetails into Prime: By, Jones, Gary
-- Created on: 3/28/2024
/* Description: These fields will be used for insert into Protocol detials display
 */
-- =================================================================================================

--Drop table if exists
DROP TABLE  onprc_ehr.eIACUCDetails;

-- Create the temp table
CREATE TABLE onprc_ehr.eIACUCDetails
(
    [rowid] [int] IDENTITY(1,1) NOT NULL,
    [Protocol_ID] [varchar](255) NOT NULL,
    [BaseProtocol] [varchar](255) NOT NULL,
    [RevisionNumber] [varchar](255) NOT NULL,
    [Template_OID] [varchar](32) NULL,
    [Protocol_Title] [varchar](255) NULL,
    [PROTOCOL_State] [varchar](250) NULL,
    [PPQ_Numbers] [varchar](255) NULL
)
;

GO
