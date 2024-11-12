-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jonesga
-- Create date: Nov,ber 12, 2024
-- Description:	Update of PRIMe Protocols using eIACUC2 Data
----THis determines Protocols that are New, Updated or EndDated
----This Procedure hadndles enddates only
-- =============================================
CREATE PROCEDURE onprc_ehr.eIACUCtoPrimeProcessing

AS
BEGIN
    --Processes to administer PRIMe protocols from eiCAUC2
    DROP TABLE IF EXISTS ##eIACUCBaseProtocolData;
    DROP TABLE IF EXISTS ##eIACUCExpiredProtocols;
    DROP TABLE IF EXISTS ##ExpiredPRIMEprotocols;
    DROP TABLE IF EXISTS ##DistincteIACUCProtocol;
    DROP TABLE IF EXISTS ##TestingProtocol;

    --Test Result Set Select * from #TestingProtocol
/*Define temp Tables for process
##TestingProtocol
##eIACUCBaseProtocolData
##DistincteIACUCProtocol
##ExpiredPRIMEprotocols
*/
/*Create ##TestingProtocol a Temp Table for Process Validation #TestingProtocol
PURPOSE: This temp table replicates ehr.protocol for testing purposed
--will be replaced when all processses are validate
*/
    Select *
    INTO ##TestingProtocol
    from ehr.protocol
    where enddate is Null
/*Create ##eIACUCBaseProtocolData
This temp table is rused to parse out the Protocol_ID
when it is longer than 10 characters which indicated the Code is for
a revised or updated Protocol i.e. TR01IP000012
*/
    Select
        p.Protocol_ID,
        CASE
            WHEN len(p.Protocol_ID) > 10 then substring(Protocol_ID,6,15)

            ELSE Protocol_ID
            END as BaseProtocol,
        CASE
            WHEN len(p.Protocol_ID) > 10 then substring(Protocol_ID,1,4)

            ELSE 'Original'
            END as RevisionNumber,
        p.Three_year_Expiration,
        p.PROTOCOL_State
    into ##eIACUCExpiredProtocols
    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS p
    where p.Protocol_State in ('expired','terminated','withdrawn')

/* Create Temp Table ##ExpiredPRIMEprotocols
This does a comparison with ehr POrotocol to determin e what needs to be updated

*/
    SELECT
        p.external_id,p.Title, e.Protocol_state,e.Three_year_Expiration,p.enddate
    into ##ExpiredPRIMEprotocols

    from ehr.Protocol p join ##eIACUCExpiredProtocols e on p.external_Id = e.BaseProtocol
    where p.enddate is Null
    --Select * from ##ExpiredPRIMEprotocols1 t
/*Create Temp Table Current ##DistincteIACUCProtocols
the challenge was that in eIACUC there is a record for each revision
so we need to get the lateesst record
*/
    Select rowid,
           Protocol_ID,
           CASE
               WHEN len(Protocol_ID) > 10 then substring(Protocol_ID,6,15)
               ELSE Protocol_ID
               END as BaseProtocol,
           CASE
               WHEN len(Protocol_ID) > 10 then substring(Protocol_ID,1,4)
               ELSE 'Original'
               END as RevisionNumber,

           Protocol_Title,
           Template_OID,
           Approval_Date,
           last_modified,
           Three_year_Expiration,
           Protocol_State
    INTO ##DistincteIACUCProtocol
    from onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
    where rowID in
          (
              SELECT rowid
              FROM (
                       SELECT *,
                              ROW_NUMBER() OVER (PARTITION BY last_modified ORDER BY last_modified DESC) AS rn
                       FROM onprc_ehr.eIACUC_PRIME_VIEW_PROTOCOLS
                   ) subquery
              WHERE rn = 1)
/* Determine what records in ehr.prtotocol (##TestingProtocol) here need to be enddated
we will use the three year renewal date as the end date of the protocol
--select * from ##TestingProtocol
--Select * from ##DistincteIACUCProtocol
--DROP TABLE IF EXISTS  ##DistincteIACUCProtocol
*/
    Select
        p.protocol,
        p.external_id,
        p.approve,
        p.enddate,
        d.BaseProtocol,
        d.RevisionNumber,
        d.PROTOCOL_State,
        d.Three_year_Expiration
    into ##PRIMEProtocolstoEndDate
    From ##TestingProtocol p join ##DistincteIACUCProtocol d on p.external_Id = d.baseProtocol
    where d.PROTOCOL_State in ('expired','withdrawn','terminated')

    /*Prior to end dating the Protocol record in Prime
    we need to insure that this will not cause orphanned records in Center Projects
    So wel will take the list of targetted records to be enddated and connect to Center Project
    and look at the assignment table to insure there are no active assignments.
    ??QUestion for Sally, is there any possible case where end dating a protocol  will affect the finance billing
    */
--Connect Center Project to Targeted recoprds to end date
--Using the Output check if any animals still assigned to a project
/*
Select * from [studyDataset].[c6d192_assignment] a
where a.project in
(
Select
    p.project

from ##PRIMEProtocolstoEndDate e join ehr.project p on e.protocol = p.protocol
where p.enddate >= '2024/11/11')
and a.enddate is Null
-- this will be used once we have ethe associated projects
*/
END
GO
--select * from ehr.project
--Select * from ##PRIMEProtocolstoEndDate
--where PROTOCOL_State in ('expired','terminated','withdrawn')--

update p
set p.enddate = e.Three_Year_Expiration,p.contacts = 'EndDate based on Protocol_State ' + e.Protocol_State
from ##TestingProtocol p join ##PRIMEProtocolstoEndDate e on p.protocol = e.protocol


--QUery that shows records that were updated
Select * from ##TestingProtocol where contacts is not null