
-- =======================================================================================================================================
-- Author:		Lakshmi Kolli
-- Create date: 2021-08-10
-- Description:	Deleting all the db files created for the Prima reports process. We dont need these anymore as we found another efficient
-- solution.
-- =======================================================================================================================================

--Drop if exists (Labkey syntax)
--Tables
EXEC core.fn_dropifexists 'Prima_CaseBase','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_CassetteBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_LabstationTypes','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideBases','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEvents','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SlideEventLocations','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_StainTests','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_SurgicalWheels','onprc_ehr','TABLE';
EXEC core.fn_dropifexists 'Prima_UserPersons','onprc_ehr','TABLE';
--Stored procs
EXEC core.fn_dropifexists 'PrimaSlideBillingReport', 'onprc_ehr', 'PROCEDURE';
EXEC core.fn_dropifexists 'PrimaBlockBillingReport', 'onprc_ehr', 'PROCEDURE';

GO