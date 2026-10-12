/************************************************************************************
 Name:          onprc_ehr.SLACensusInvestigatorUpdate
 Author:        Lakshmi Kolli
 Created:       June 2026
 Description:
 Updates sla.census.investigatorId directly from ehr.project and onprc_ehr.investigators.

 The procedure updates census records when:
•	The census date is on or after September 1, 2016
•	The census investigatorId is null
•	The census project matches an ehr.project record
•	The project has a valid investigator
************************************************************************************/

--Drop Stored proc if exists
EXEC core.fn_dropifexists 'SLACensusInvestigatorUpdate', 'onprc_ehr', 'PROCEDURE';
GO

--Create stored procedure to update the investigators data in sla.census table.
CREATE PROCEDURE [onprc_ehr].[SLACensusInvestigatorUpdate]
AS

BEGIN

UPDATE c
SET c.investigatorId = i.objectid
    FROM sla.census c
        INNER JOIN ehr.project p
ON p.project = c.project
    INNER JOIN onprc_ehr.investigators i
    ON i.rowId = p.investigatorId
WHERE c.date >= '2016/09/01'
  AND c.investigatorId IS NULL
  AND i.objectid IS NOT NULL

END;
Go